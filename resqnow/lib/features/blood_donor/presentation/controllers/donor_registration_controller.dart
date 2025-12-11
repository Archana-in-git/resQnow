// lib/features/blood_donor/presentation/controllers/donor_registration_controller.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/usecases/register_donor.dart';
import 'package:resqnow/features/presentation/controllers/location_controller.dart';

class DonorRegistrationController extends ChangeNotifier {
  final RegisterDonor registerDonorUseCase;
  final LocationController locationController;

  DonorRegistrationController({
    required this.registerDonorUseCase,
    required this.locationController,
  });

  bool isLoading = false;
  String? errorMessage;

  String address = "";

  // Only GPS coordinates now
  double? gpsLat;
  double? gpsLng;

  // Public getters for the UI
  double? get latitude => gpsLat;
  double? get longitude => gpsLng;

  // ------------------------------
  // FETCH LOCATION USING GPS
  // ------------------------------
  Future<void> fetchLocation() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await locationController.refreshLocation();

      gpsLat = locationController.latitude;
      gpsLng = locationController.longitude;

      if (gpsLat == null || gpsLng == null) {
        throw Exception("GPS unavailable");
      }

      address = locationController.locationText;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = "Unable to detect location.";
      isLoading = false;
      notifyListeners();
    }
  }

  // ------------------------------
  // SET ADDRESS MANUALLY
  // ------------------------------
  void setManualAddress(String newAddress) {
    address = newAddress.trim();
    notifyListeners();
  }

  // ------------------------------
  // REGISTER DONOR
  // ------------------------------
  Future<bool> register({
    required String name,
    required int age,
    required String gender,
    required String bloodGroup,
    required String phone,
    required List<String> conditions,
    String? notes,
    String? addressInput,
    double? latitudeInput,
    double? longitudeInput,
  }) async {
    errorMessage = null;

    final resolvedAddress =
        (addressInput != null && addressInput.trim().isNotEmpty)
        ? addressInput.trim()
        : (address.trim().isNotEmpty ? address.trim() : '');

    if (resolvedAddress.isEmpty) {
      errorMessage = "Address is required.";
      notifyListeners();
      return false;
    }

    final double? finalLat = latitudeInput ?? gpsLat;
    final double? finalLng = longitudeInput ?? gpsLng;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      errorMessage = "User is not signed in.";
      notifyListeners();
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      final donor = BloodDonor(
        id: user.uid,
        name: name,
        age: age,
        gender: gender,
        bloodGroup: bloodGroup,
        phone: phone,
        phoneVerified: true,
        latitude: finalLat,
        longitude: finalLng,
        address: resolvedAddress,
        lastDonationDate: null,
        totalDonations: 0,
        isAvailable: true,
        medicalConditions: conditions,
        notes: notes,
        profileImageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await registerDonorUseCase(donor);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = "Failed to register donor.";
      notifyListeners();
      return false;
    }
  }
}
