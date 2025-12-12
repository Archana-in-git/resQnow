// features/presentation/controllers/location_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
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

  // ----------------------------------------------------------
  // NEW — district & town system
  // ----------------------------------------------------------
  String? detectedDistrict;
  List<String> availableTowns = [];

  Map<String, List<String>> _districtTownMap = {};

  // PUBLIC GETTERS
  String get locationText => _locationText;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;

  // ----------------------------------------------------------
  // INITIALIZER
  // ----------------------------------------------------------
  Future<void> initialize() async {
    if (_initialised) return;
    _initialised = true;

    await _loadKeralaTownJson();
    await refreshLocation();
  }

  // ----------------------------------------------------------
  // LOAD JSON DATA FOR DISTRICT → TOWNS
  // ----------------------------------------------------------
  Future<void> _loadKeralaTownJson() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/kerala_towns.json',
      );

      final Map<String, dynamic> data = json.decode(jsonString);

      _districtTownMap = data.map((district, towns) {
        return MapEntry(district, List<String>.from(towns));
      });
    } catch (e) {
      debugPrint("ERROR loading Kerala towns JSON: $e");
      _districtTownMap = {};
    }
  }

  // ----------------------------------------------------------
  // REFRESH LOCATION MAIN LOGIC
  // ----------------------------------------------------------
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

    // 2️⃣ Check GPS
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _locationText = 'Enable GPS to detect location';
      notifyListeners();

      await Geolocator.openLocationSettings();
      final enabled = await _waitForGPSOn(seconds: 30);

      if (!enabled) {
        _locationText = 'Please enable location services';
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    // 3️⃣ Fetch GPS position
    final Position? position = await LocationService.getCurrentPosition();
    if (position == null) {
      _locationText = 'Unable to detect location';
      _isLoading = false;
      notifyListeners();
      return;
    }

    latitude = position.latitude;
    longitude = position.longitude;

    // 4️⃣ Reverse geocode district
    await _resolveDistrict(position);

    // 5️⃣ Start live updates
    await _startPositionStream();

    _isLoading = false;
    notifyListeners();
  }

  // ----------------------------------------------------------
  // REVERSE GEOCODE DISTRICT + UPDATE TOWNS LIST
  // ----------------------------------------------------------
  Future<void> _resolveDistrict(Position pos) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isEmpty) return;

      final pm = placemarks.first;

      // Extract district safely
      final district = pm.subAdministrativeArea?.trim();

      if (district != null && district.isNotEmpty) {
        detectedDistrict = district;

        // Load towns for this district
        availableTowns = _districtTownMap[district] ?? [];
      }

      // Update main label (city + country)
      final city = pm.locality ?? pm.subLocality ?? '';
      final country = pm.country ?? '';
      final label = [
        city,
        country,
      ].where((e) => e.trim().isNotEmpty).join(', ');

      _locationText = label.isNotEmpty
          ? label
          : '${pos.latitude}, ${pos.longitude}';
    } catch (e) {
      debugPrint("District resolve failed: $e");
      detectedDistrict = null;
      availableTowns = [];
    }
  }

  // ----------------------------------------------------------
  // GPS ON WAIT
  // ----------------------------------------------------------
  Future<bool> _waitForGPSOn({int seconds = 30}) async {
    final end = DateTime.now().add(Duration(seconds: seconds));

    while (DateTime.now().isBefore(end)) {
      if (await Geolocator.isLocationServiceEnabled()) return true;
      await Future.delayed(const Duration(seconds: 1));
    }

    return await Geolocator.isLocationServiceEnabled();
  }

  // ----------------------------------------------------------
  // LIVE LOCATION STREAM HANDLING
  // ----------------------------------------------------------
  Future<void> _startPositionStream() async {
    await _positionSubscription?.cancel();

    _positionSubscription =
        LocationService.getPositionStream(distanceFilter: 20).listen(
          (Position position) async {
            latitude = position.latitude;
            longitude = position.longitude;

            // update district only if it changed
            final oldDistrict = detectedDistrict;

            await _resolveDistrict(position);

            if (oldDistrict != detectedDistrict) {
              notifyListeners();
            }
          },
          onError: (_) {
            _locationText = 'Location unavailable';
            notifyListeners();
          },
        );
  }

  // ----------------------------------------------------------
  // MANUAL SET LOCATION (optional)
  // ----------------------------------------------------------
  void setManualLocation(String label) {
    _locationText = label;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
