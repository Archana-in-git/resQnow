import 'package:flutter/material.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/usecases/get_donor_by_id.dart';
import 'package:resqnow/features/blood_donor/data/services/blood_donor_service.dart';

class DonorDetailsController extends ChangeNotifier {
  final GetDonorById getDonorByIdUseCase;
  final BloodDonorService bloodDonorService;

  DonorDetailsController({
    required this.getDonorByIdUseCase,
    required this.bloodDonorService,
  });

  bool isLoading = false;
  String? errorMessage;
  BloodDonor? donor;

  bool isSubmittingCallRequest = false;
  String? callRequestError;

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

  /// Submit a call request to the donor
  Future<String?> submitCallRequest() async {
    if (donor == null) {
      callRequestError = 'Donor information not available';
      notifyListeners();
      return null;
    }

    try {
      isSubmittingCallRequest = true;
      callRequestError = null;
      notifyListeners();

      final requestId = await bloodDonorService.submitCallRequest(
        donorId: donor!.id,
        donorName: donor!.name,
        donorPhone: donor!.phone,
      );

      isSubmittingCallRequest = false;
      notifyListeners();

      return requestId;
    } catch (e) {
      callRequestError = e.toString();
      isSubmittingCallRequest = false;
      notifyListeners();
      return null;
    }
  }
}
