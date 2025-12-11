import 'package:flutter/material.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/usecases/get_donor_by_id.dart';

class DonorDetailsController extends ChangeNotifier {
  final GetDonorById getDonorByIdUseCase;

  DonorDetailsController({required this.getDonorByIdUseCase});

  bool isLoading = false;
  String? errorMessage;
  BloodDonor? donor;

  Future<void> loadDonor(String donorId) async {
    try {
      isLoading = true;
      notifyListeners();

      donor = await getDonorByIdUseCase(donorId);

      if (donor == null) {
        errorMessage = "Donor not found.";
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }
}
