import 'package:flutter/material.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/usecases/filter_donors.dart';

class DonorFilterController extends ChangeNotifier {
  final FilterDonors filterDonorsUseCase;

  DonorFilterController({required this.filterDonorsUseCase});

  bool isLoading = false;
  String? errorMessage;
  List<BloodDonor> filteredDonors = [];

  // Filter fields
  String? selectedBloodGroup;
  String? selectedGender;
  int? minAge;
  int? maxAge;
  bool? isAvailable;

  // Apply filters
  Future<void> applyFilters() async {
    try {
      isLoading = true;
      notifyListeners();

      filteredDonors = await filterDonorsUseCase(
        bloodGroup: selectedBloodGroup,
        gender: selectedGender,
        minAge: minAge,
        maxAge: maxAge,
        isAvailable: isAvailable,
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Reset fields
  void resetFilters() {
    selectedBloodGroup = null;
    selectedGender = null;
    minAge = null;
    maxAge = null;
    isAvailable = null;
    notifyListeners();
  }
}
