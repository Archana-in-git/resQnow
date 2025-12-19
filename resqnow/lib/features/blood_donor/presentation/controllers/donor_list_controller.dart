import 'package:flutter/material.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/usecases/get_donors.dart';
import 'package:resqnow/features/presentation/controllers/location_controller.dart';

class DonorListController extends ChangeNotifier {
  final GetDonorsByDistrict getDonorsByDistrictUseCase;
  final GetDonorsByTown getDonorsByTownUseCase;
  final LocationController locationController;

  DonorListController({
    required this.getDonorsByDistrictUseCase,
    required this.getDonorsByTownUseCase,
    required this.locationController,
  });

  bool isLoading = false;
  String? errorMessage;
  List<BloodDonor> donors = [];

  /// NEW — holds current district & town selection
  String? detectedDistrict;
  String? selectedTown;
  String? detectedPincode;

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

      // Get the DYNAMICALLY detected district (only if pincode matched our dataset)
      detectedDistrict = locationController.detectedDistrict;

      if (detectedDistrict == null || detectedDistrict!.isEmpty) {
        errorMessage =
            "Unable to determine your district automatically. Please select manually.";
        isLoading = false;
        notifyListeners();
      }

      // ✅ STEP 2: FETCH ALL DONORS IN THE DETECTED DISTRICT
      // Only fetch if auto-detection succeeded
      if (detectedDistrict != null && detectedDistrict!.isNotEmpty) {
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
}
