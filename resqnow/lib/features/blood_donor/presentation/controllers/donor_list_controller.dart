import 'package:flutter/material.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/usecases/get_donors.dart';
import 'package:resqnow/features/presentation/controllers/location_controller.dart';

class DonorListController extends ChangeNotifier {
  final GetDonorsNearby getDonorsNearbyUseCase;
  final LocationController locationController;

  DonorListController({
    required this.getDonorsNearbyUseCase,
    required this.locationController,
  });

  bool isLoading = false;
  String? errorMessage;
  List<BloodDonor> donors = [];

  double radiusKm = 10;

  Future<void> loadDonors() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await locationController.initialize();

      final lat = locationController.latitude;
      final lng = locationController.longitude;

      if (lat == null || lng == null) {
        errorMessage = 'Unable to determine current location.';
        isLoading = false;
        notifyListeners();
        return;
      }

      donors = await getDonorsNearbyUseCase(
        latitude: lat,
        longitude: lng,
        radiusKm: radiusKm,
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadDonors();
  }
}
