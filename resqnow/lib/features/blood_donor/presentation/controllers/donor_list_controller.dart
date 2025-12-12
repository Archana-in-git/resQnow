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

  // ---------------------------------------------------------------------------
  // Load donors by detecting district via GPS
  // ---------------------------------------------------------------------------
  Future<void> loadDonors() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // initialize GPS + reverse geocoding
      await locationController.initialize();

      detectedDistrict = locationController.detectedDistrict;

      if (detectedDistrict == null || detectedDistrict!.isEmpty) {
        errorMessage = "Unable to determine district from location.";
        isLoading = false;
        notifyListeners();
        return;
      }

      // FETCH ALL DONORS BY DISTRICT
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
}
