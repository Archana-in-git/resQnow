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

  // NEW: final resolved values
  String? detectedDistrict; // always “Palakkad” for your region
  String?
  selectedTown; // NOT auto-detected - user must manually select from donor list UI
  String? detectedPincode; // captured pincode from reverse geocoding
  List<String> availableTowns = [];
  bool _userManuallySelectedTown = false; // track user manual selection

  // JSON DATA
  Map<String, List<String>> _districtTownMap = {};
  List<Map<String, dynamic>> _pincodeAreaList = [];

  String get locationText => _locationText;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;

  // INITIALIZER
  Future<void> initialize() async {
    if (_initialised) return;
    _initialised = true;

    await _loadKeralaTownJson();
    await _loadPincodeJson();
    await refreshLocation();
  }

  // LOAD KERALA TOWN JSON
  Future<void> _loadKeralaTownJson() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/kerala_towns.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);
      _districtTownMap = data.map(
        (district, towns) => MapEntry(district, List<String>.from(towns)),
      );
    } catch (e) {
      debugPrint("ERROR loading Kerala towns JSON: $e");
    }
  }

  // LOAD PINCODE → TOWN JSON
  Future<void> _loadPincodeJson() async {
    try {
      debugPrint(
        "🔄 Loading pincode JSON from assets/data/pin_palakkad.json...",
      );

      final jsonString = await rootBundle.loadString(
        'assets/data/pin_palakkad.json',
      );

      debugPrint(
        "✅ JSON file loaded successfully. Size: ${jsonString.length} bytes",
      );

      final List<dynamic> data = json.decode(jsonString);
      _pincodeAreaList = data.map((e) => Map<String, dynamic>.from(e)).toList();

      debugPrint(
        "✅ Pincode JSON parsed successfully. Total entries: ${_pincodeAreaList.length}",
      );
    } catch (e) {
      debugPrint("❌ ERROR loading pincode JSON: $e");
      debugPrint("❌ Stack trace: ${StackTrace.current}");
      _pincodeAreaList = [];
    }
  }

  // REFRESH LOCATION
  Future<void> refreshLocation() async {
    _isLoading = true;
    notifyListeners();

    // Request permission
    final granted = await PermissionService.requestLocationPermission();
    _hasPermission = granted;

    if (!granted) {
      _locationText = 'Location permission needed';
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Check GPS
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

    // Fetch position
    final Position? position = await LocationService.getCurrentPosition();
    if (position == null) {
      _locationText = 'Unable to detect location';
      _isLoading = false;
      notifyListeners();
      return;
    }

    latitude = position.latitude;
    longitude = position.longitude;

    // Reverse geocode → detect district + town
    await _resolveDistrictAndTown(position);

    // Start listening to future updates
    await _startPositionStream();

    _isLoading = false;
    notifyListeners();
  }

  // DETECT DISTRICT + TOWN (dynamically from pincode)
  Future<void> _resolveDistrictAndTown(Position pos) async {
    try {
      // Reset values
      detectedDistrict = null;
      if (!_userManuallySelectedTown) {
        selectedTown = null;
      }
      availableTowns = [];

      // Try to get reverse geocoded address for UI display
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;

        // 🎯 STEP 1: Try to extract district from PINCODE (most reliable)
        final postalCode = pm.postalCode?.trim();
        detectedPincode = postalCode;

        if (postalCode != null && postalCode.isNotEmpty) {
          final normalizedPostalCode = postalCode.trim();

          debugPrint(
            "🔍 Looking for pincode: '$normalizedPostalCode' (type: ${normalizedPostalCode.runtimeType})",
          );
          debugPrint("📊 Total pincodes loaded: ${_pincodeAreaList.length}");

          final matches = _pincodeAreaList.where((e) {
            final pin = e['pincode']?.toString().trim();
            return pin == normalizedPostalCode;
          }).toList();

          debugPrint("🎯 Total matches found: ${matches.length}");

          if (matches.isNotEmpty) {
            // ✅ STEP 1: Get district from first match (all should have same)
            detectedDistrict = matches.first['district'];
            debugPrint("✅ District detected: $detectedDistrict");

            // ✅ STEP 2: Derive unique towns from the pincode matches
            // (NOT from the master district town list)
            final townSet = <String>{};
            for (final match in matches) {
              final town = match['town']?.toString().trim();
              if (town != null && town.isNotEmpty && town != 'NA') {
                townSet.add(town);
              }
            }
            availableTowns = townSet.toList();
            availableTowns.sort(); // For consistent ordering

            debugPrint("✅ Towns derived from pincode: $availableTowns");

            // Town is NOT auto-selected - user must manually choose from available towns
          } else {
            debugPrint(
              "⚠️ Pincode $normalizedPostalCode not found in local dataset",
            );
          }
        } else {
          debugPrint("⚠️ No postal code in reverse geocoding result");
        }

        // UI label with city/locality (for display only)
        final city = pm.locality ?? pm.subLocality ?? '';
        final country = pm.country ?? '';
        final label = [city, country].where((e) => e.isNotEmpty).join(', ');

        _locationText = label.isNotEmpty
            ? label
            : '${pos.latitude}, ${pos.longitude}';
      } else {
        // No placemark available
        _locationText = '${pos.latitude}, ${pos.longitude}';
        debugPrint("⚠️ No placemarks found for coordinates");
      }
    } catch (e) {
      debugPrint("❌ District resolution error: $e");
      detectedDistrict = null;
      availableTowns = [];
      _locationText = '${pos.latitude}, ${pos.longitude}';
    }
  }

  // WAIT FOR GPS
  Future<bool> _waitForGPSOn({int seconds = 30}) async {
    final end = DateTime.now().add(Duration(seconds: seconds));

    while (DateTime.now().isBefore(end)) {
      if (await Geolocator.isLocationServiceEnabled()) return true;
      await Future.delayed(const Duration(seconds: 1));
    }

    return await Geolocator.isLocationServiceEnabled();
  }

  // LIVE STREAM
  Future<void> _startPositionStream() async {
    await _positionSubscription?.cancel();

    _positionSubscription =
        LocationService.getPositionStream(distanceFilter: 20).listen(
          (Position position) async {
            latitude = position.latitude;
            longitude = position.longitude;

            // Store previous values to check if anything actually changed
            final previousDistrict = detectedDistrict;
            final previousPincode = detectedPincode;
            final previousTown = selectedTown;

            await _resolveDistrictAndTown(position);

            // Only notify if district or pincode actually changed
            if (detectedDistrict != previousDistrict ||
                detectedPincode != previousPincode ||
                (selectedTown != previousTown && !_userManuallySelectedTown)) {
              debugPrint(
                "📍 Location changed: District=$detectedDistrict, Pincode=$detectedPincode",
              );
              notifyListeners();
            } else {
              debugPrint(
                "⏭️ Location update received but no district/pincode/town change - skipping notify",
              );
            }
          },
          onError: (_) {
            _locationText = 'Location unavailable';
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  // PUBLIC: Allow UI to set manual town selection
  void setManualTownSelection(String town) {
    selectedTown = town;
    _userManuallySelectedTown = true;
    notifyListeners();
  }
}
