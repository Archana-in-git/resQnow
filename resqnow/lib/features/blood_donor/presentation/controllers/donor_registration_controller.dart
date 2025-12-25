// lib/features/blood_donor/presentation/controllers/donor_registration_controller.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/usecases/register_donor.dart';

class DonorRegistrationController extends ChangeNotifier {
  final RegisterDonor registerDonorUseCase;

  DonorRegistrationController({required this.registerDonorUseCase});

  bool isLoading = false;
  String? errorMessage;

  // Optional preview text
  String addressPreview = "";

  // -------------------------------------------------------------
  // REGISTER DONOR
  // -------------------------------------------------------------
  Future<bool> register({
    required String name,
    required int age,
    required String gender,
    required String bloodGroup,
    required String phone,
    required List<String> conditions,
    required Map<String, String> permanentAddressComponents,
    required String addressInput,
    Map<String, dynamic>? lastSeen,
    String? notes,

    /// NEW OPTIONAL FIELD
    String? profileImageUrl,
  }) async {
    errorMessage = null;

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

        permanentLocation: null,
        permanentAddress: permanentAddressComponents,

        /// 🔥 FLATTENED FIELDS (CRITICAL FOR QUERIES)
        country: permanentAddressComponents['country'],
        state: permanentAddressComponents['state'],
        district: permanentAddressComponents['district'],
        town: permanentAddressComponents['city'],
        pincode: permanentAddressComponents['pincode'],

        addressString: addressInput,
        lastSeen: lastSeen,

        medicalConditions: conditions,
        notes: notes,

        profileImageUrl: profileImageUrl,

        isAvailable: true,
        totalDonations: 0,

        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print("📍 FLATTENED LOCATION CHECK:");
      print({
        "state": donor.state,
        "district": donor.district,
        "town": donor.town,
        "pincode": donor.pincode,
      });

      print("🩸 DONOR REGISTRATION PAYLOAD:");
      print(donor.toMap());

      await registerDonorUseCase(donor);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = "Failed to register donor. Error: $e";
      notifyListeners();
      return false;
    }
  }
}
