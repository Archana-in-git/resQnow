import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/usecases/get_donors.dart';
import 'package:resqnow/domain/usecases/get_all_donors.dart';
import 'package:resqnow/features/presentation/controllers/location_controller.dart';

class DonorListController extends ChangeNotifier {
  final GetDonorsByDistrict getDonorsByDistrictUseCase;
  final GetDonorsByTown getDonorsByTownUseCase;
  final GetAllDonors getAllDonorsUseCase;
  final LocationController locationController;

  DonorListController({
    required this.getDonorsByDistrictUseCase,
    required this.getDonorsByTownUseCase,
    required this.getAllDonorsUseCase,
    required this.locationController,
  }) {
    // Listen to LocationController changes so UI updates when district is detected
    locationController.addListener(_onLocationChanged);
  }

  bool isLoading = false;
  String? errorMessage;
  List<BloodDonor> donors = [];

  /// Filter properties
  String? selectedBloodGroup;
  bool? isAvailable;

  /// NEW — holds current district & town selection
  String? detectedDistrict;
  String? selectedTown;
  String? detectedPincode;

  /// Towns available for the selected district (from JSON)
  List<String> availableTownsForDistrict = [];

  /// Track if user manually cleared district filter
  bool userClearedDistrict = false;

  /// Track the last district we fetched donors for to avoid duplicate fetches
  String? _lastFetchedDistrict;

  // Listen to LocationController changes
  void _onLocationChanged() {
    // Only auto-apply detected district if user hasn't manually cleared it
    if (!userClearedDistrict) {
      final newDistrict = locationController.detectedDistrict;
      detectedDistrict = newDistrict;

      // Reset town when district changes
      selectedTown = null;

      // Only fetch if district actually changed
      if (newDistrict != null &&
          newDistrict.isNotEmpty &&
          newDistrict != _lastFetchedDistrict) {
        _fetchDonorsForDistrict(newDistrict);
        _lastFetchedDistrict = newDistrict;
      }
    }
    notifyListeners();
  }

  // Helper method to fetch donors for a district
  Future<void> _fetchDonorsForDistrict(String district) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      donors = await getDonorsByDistrictUseCase(district);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    locationController.removeListener(_onLocationChanged);
    super.dispose();
  }

  // Load towns from cities_kerala.json for a given district
  Future<List<String>> loadTownsForDistrict(String district) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/cities_kerala.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);
      final Map<String, dynamic> keralaData = data['Kerala'] ?? {};
      final List<dynamic> towns = keralaData[district] ?? [];
      availableTownsForDistrict = towns.map((t) => t.toString()).toList();
      notifyListeners();
      return availableTownsForDistrict;
    } catch (e) {
      availableTownsForDistrict = [];
      notifyListeners();
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Load donors by detecting district via GPS + pincode lookup
  // ---------------------------------------------------------------------------
  Future<void> loadDonors() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Initialize GPS + reverse geocoding + pincode lookup
      await locationController.initialize();

      // Get the DYNAMICALLY detected district
      // (LocationController's listener will trigger fetching donors)
      detectedDistrict = locationController.detectedDistrict;

      // If auto-detection didn't work, just stop loading but don't show error
      if (detectedDistrict == null || detectedDistrict!.isEmpty) {
        isLoading = false;
        notifyListeners();
        return;
      }

      // If auto-detection worked, the listener (_onLocationChanged) will handle fetching
      // But we also fetch here in case we initialized after the listener fired
      if (donors.isEmpty) {
        donors = await getDonorsByDistrictUseCase(detectedDistrict!);
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // User chooses a town → refine donor list
  // ---------------------------------------------------------------------------
  Future<void> loadDonorsByTown(String town) async {
    selectedTown = town;

    if (detectedDistrict == null) return;

    try {
      isLoading = true;
      notifyListeners();

      donors = await getDonorsByTownUseCase(
        district: detectedDistrict!,
        town: selectedTown!,
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Refresh donors — reload by district
  // ---------------------------------------------------------------------------
  Future<void> refresh() async {
    await loadDonors();
  }

  // ---------------------------------------------------------------------------
  // MANUAL DISTRICT SELECTION (fallback)
  // ---------------------------------------------------------------------------
  Future<void> setManualDistrict(String district) async {
    detectedDistrict = district;
    selectedTown = null;
    errorMessage = null;
    userClearedDistrict =
        false; // User selected a district, so allow auto-detection again

    try {
      isLoading = true;
      notifyListeners();

      // ✅ DISTRICT-LEVEL FETCH (IMPORTANT FIX)
      donors = await getDonorsByDistrictUseCase(detectedDistrict!);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // MANUAL TOWN SELECTION
  // ---------------------------------------------------------------------------
  Future<void> setManualTown(String town) async {
    selectedTown = town;

    if (detectedDistrict == null) return;

    try {
      isLoading = true;
      notifyListeners();

      donors = await getDonorsByTownUseCase(
        district: detectedDistrict!,
        town: selectedTown!,
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // CLEAR TOWN FILTER — show all donors for the district
  // ---------------------------------------------------------------------------
  Future<void> clearTownFilter() async {
    selectedTown = null;

    if (detectedDistrict == null) return;

    try {
      isLoading = true;
      notifyListeners();

      // Fetch all donors for the district (no town filter)
      donors = await getDonorsByDistrictUseCase(detectedDistrict!);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // CLEAR DISTRICT FILTER — clear both district and town
  // ---------------------------------------------------------------------------
  Future<void> clearAllFilters() async {
    detectedDistrict = null;
    selectedTown = null;
    selectedBloodGroup = null;
    isAvailable = null;
    errorMessage = null;
    userClearedDistrict = true; // Prevent auto-detection from overriding this

    try {
      isLoading = true;
      notifyListeners();

      // Fetch ALL donors from all districts
      final result = await getAllDonorsUseCase();

      donors =
          result; // ✅ Explicitly assign result (already safe from use case)

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }
}
