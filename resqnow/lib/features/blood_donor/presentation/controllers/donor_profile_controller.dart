// lib/features/blood_donor/presentation/controllers/donor_profile_controller.dart

import 'package:flutter/material.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/usecases/get_my_donor_profile.dart';
import 'package:resqnow/domain/usecases/update_donor.dart';

class DonorProfileController extends ChangeNotifier {
  final GetMyDonorProfile getMyDonorProfileUseCase;
  final UpdateDonor updateDonorUseCase;

  DonorProfileController({
    required this.getMyDonorProfileUseCase,
    required this.updateDonorUseCase,
  });

  BloodDonor? donor;
  bool isLoading = false;
  String? errorMessage;

  /// Check if current user is registered as a donor (without loading full profile)
  Future<bool> isDonor() async {
    try {
      donor = await getMyDonorProfileUseCase();
      return donor != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadProfile() async {
    try {
      isLoading = true;
      notifyListeners();

      donor = await getMyDonorProfileUseCase();

      if (donor == null) {
        errorMessage = "Donor profile not found.";
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Update availability toggle
  Future<void> updateAvailability(bool value) async {
    if (donor == null) return;

    try {
      donor = donor!.copyWith(isAvailable: value);
      notifyListeners();

      await updateDonorUseCase(donor!);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
