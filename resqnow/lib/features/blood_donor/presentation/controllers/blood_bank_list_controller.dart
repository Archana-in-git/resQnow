import 'package:flutter/material.dart';
import 'package:resqnow/domain/entities/blood_bank.dart';
import 'package:resqnow/domain/usecases/get_blood_banks_nearby.dart';
import 'package:resqnow/features/presentation/controllers/location_controller.dart';

class BloodBankListController extends ChangeNotifier {
  final GetBloodBanksNearby getBloodBanksNearby;
  final LocationController locationController;

  BloodBankListController({
    required this.getBloodBanksNearby,
    required this.locationController,
  });

  bool isLoading = false;
  String? error;
  List<BloodBank> bloodBanks = [];

  Future<void> loadBloodBanks() async {
    final lat = locationController.latitude;
    final lng = locationController.longitude;

    if (lat == null || lng == null) {
      error = "Location not ready.";
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      error = null;
      notifyListeners();

      bloodBanks = await getBloodBanksNearby(latitude: lat, longitude: lng);
    } catch (e) {
      error = "Failed to load blood banks: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
