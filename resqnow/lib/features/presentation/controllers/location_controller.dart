// features/presentation/controllers/location_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:resqnow/core/services/location_service.dart';
import 'package:resqnow/core/services/permission_service.dart';

class LocationController extends ChangeNotifier {
  String _locationText = "Fetching location...";
  String get locationText => _locationText;

  Position? lastPosition;
  StreamSubscription<Position>? _positionSub;

  bool _isUpdating = false;

  /// Start listening for location updates (real-time).
  Future<void> startLocationUpdates({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
    int waitSeconds = 30,
  }) async {
    if (_isUpdating) return;
    _isUpdating = true;

    final granted = await PermissionService.requestLocationPermission();
    if (!granted) {
      _locationText = "Enable location permission";
      notifyListeners();
      _isUpdating = false;
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();

      final end = DateTime.now().add(Duration(seconds: waitSeconds));
      while (DateTime.now().isBefore(end)) {
        await Future.delayed(const Duration(seconds: 1));
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) break;
      }

      if (!serviceEnabled) {
        _locationText = "Please enable location services";
        notifyListeners();
        _isUpdating = false;
        return;
      }
    }

    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos != null) {
        lastPosition = pos;
        final label = await LocationService.getCityCountryFromPosition(pos);
        _locationText =
            label ??
            "${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}";
        notifyListeners();
      } else {
        _locationText = "Location unavailable";
        notifyListeners();
      }
    } catch (_) {
      _locationText = "Location unavailable";
      notifyListeners();
    }

    _positionSub?.cancel();
    _positionSub =
        LocationService.getPositionStream(
          accuracy: accuracy,
          distanceFilter: distanceFilter,
        ).listen(
          (position) async {
            lastPosition = position;
            final label = await LocationService.getCityCountryFromPosition(
              position,
            );
            _locationText =
                label ??
                "${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}";
            notifyListeners();
          },
          onError: (e) {
            _locationText = "Location unavailable";
            notifyListeners();
          },
        );

    _isUpdating = false;
  }

  /// Backwards-compatible alias used in main.dart
  Future<void> fetchLocation() async => startLocationUpdates();

  /// Call when app resumes; will try again if permission/service changed.
  Future<void> onAppResumed() async {
    final perm = await Geolocator.checkPermission();
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if ((perm == LocationPermission.always ||
            perm == LocationPermission.whileInUse) &&
        serviceEnabled) {
      await startLocationUpdates();
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}
