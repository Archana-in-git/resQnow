// features/presentation/controllers/location_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:resqnow/core/services/location_service.dart';
import 'package:resqnow/core/services/permission_service.dart';

class LocationController extends ChangeNotifier {
  String _locationText = 'Detecting location...';
  bool _isLoading = false;
  bool _hasPermission = false;
  bool _initialised = false;

  String get locationText => _locationText;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;

  Future<void> initialize() async {
    if (_initialised) return;
    _initialised = true;
    await refreshLocation();
  }

  Future<void> refreshLocation() async {
    _isLoading = true;
    notifyListeners();

    final granted = await PermissionService.requestLocationPermission();
    _hasPermission = granted;

    if (!granted) {
      _locationText = 'Location permission needed';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final Position? position = await LocationService.getCurrentPosition();
    if (position != null) {
      final label = await LocationService.getCityCountryFromPosition(position);
      _locationText =
          label ??
          '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
    } else {
      _locationText = 'Unable to detect location';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setManualLocation(String label) {
    _locationText = label;
    notifyListeners();
  }
}
