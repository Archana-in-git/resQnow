// features/presentation/controllers/location_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:resqnow/core/services/location_service.dart';
import 'package:resqnow/core/services/permission_service.dart';

class LocationController extends ChangeNotifier {
  String _locationText = 'Detecting location...';
  bool _isLoading = false;
  bool _hasPermission = false;
  bool _initialised = false;

  StreamSubscription<Position>? _positionSubscription;

  double? latitude;
  double? longitude;

  String get locationText => _locationText;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;

  // INITIALIZER
  Future<void> initialize() async {
    if (_initialised) return;
    _initialised = true;
    await refreshLocation();
  }

  // 🔥 Wait for GPS to turn on after user opens settings
  Future<bool> _waitForGPSOn({int seconds = 30}) async {
    final end = DateTime.now().add(Duration(seconds: seconds));

    while (DateTime.now().isBefore(end)) {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (enabled) return true;

      await Future.delayed(const Duration(seconds: 1));
    }

    return await Geolocator.isLocationServiceEnabled();
  }

  // MAIN REFRESH LOGIC
  Future<void> refreshLocation() async {
    _isLoading = true;
    notifyListeners();

    // 1️⃣ Request Permission
    final granted = await PermissionService.requestLocationPermission();
    _hasPermission = granted;

    if (!granted) {
      _locationText = 'Location permission needed';
      _isLoading = false;
      notifyListeners();
      return;
    }

    // 2️⃣ Check GPS / Location Services
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _locationText = 'Enable GPS to detect location';
      notifyListeners();

      // Open settings to enable GPS
      await Geolocator.openLocationSettings();

      // 🔥 Wait for the user to actually turn it on
      final turnedOn = await _waitForGPSOn(seconds: 30);

      if (!turnedOn) {
        _locationText = 'Please enable location services';
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    // 3️⃣ Fetch Current Position
    final Position? position = await LocationService.getCurrentPosition();

    if (position != null) {
      latitude = position.latitude;
      longitude = position.longitude;

      final result = await LocationService.getCityCountryFromPosition(position);

      _locationText = _resolveLocationLabel(
        result,
        fallback:
            '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}',
      );

      await _startPositionStream();
    } else {
      _locationText = 'Unable to detect location';
    }

    _isLoading = false;
    notifyListeners();
  }

  // LIVE STREAM UPDATES
  Future<void> _startPositionStream() async {
    await _positionSubscription?.cancel();

    _positionSubscription =
        LocationService.getPositionStream(distanceFilter: 20).listen(
          (Position position) async {
            latitude = position.latitude;
            longitude = position.longitude;

            final result = await LocationService.getCityCountryFromPosition(
              position,
            );

            _locationText = _resolveLocationLabel(
              result,
              fallback:
                  '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}',
            );

            notifyListeners();
          },
          onError: (_) {
            _locationText = 'Location unavailable';
            notifyListeners();
          },
        );
  }

  void setManualLocation(String label) {
    _locationText = label;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  String _resolveLocationLabel(dynamic result, {required String fallback}) {
    if (result is String && result.trim().isNotEmpty) {
      return result;
    }
    if (result is Placemark) {
      final city = result.locality?.trim().isNotEmpty == true
          ? result.locality!.trim()
          : result.subAdministrativeArea?.trim() ?? '';
      final country = result.country?.trim() ?? '';
      final parts = [city, country]
          .where((part) => part.trim().isNotEmpty)
          .map((part) => part.trim())
          .toList();
      if (parts.isNotEmpty) {
        return parts.join(', ');
      }
    }
    return fallback;
  }
}
