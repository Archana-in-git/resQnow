// lib/data/repositories/blood_donor_repository_impl.dart

import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/repositories/blood_donor_repository.dart';
import 'package:resqnow/features/blood_donor/data/services/blood_donor_service.dart';

class BloodDonorRepositoryImpl implements BloodDonorRepository {
  final BloodDonorService service;

  BloodDonorRepositoryImpl({required this.service});

  @override
  Future<void> registerDonor(BloodDonor donor) async {
    try {
      await service.registerDonor(donor);
    } catch (e) {
      // Optionally wrap or log the error
      rethrow;
    }
  }

  @override
  Future<void> updateDonor(BloodDonor donor) async {
    try {
      await service.updateDonor(donor);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BloodDonor?> getMyDonorProfile() async {
    try {
      return await service.getMyDonorProfile();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isUserDonor() async {
    try {
      return await service.isUserDonor();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BloodDonor?> getDonorById(String donorId) async {
    try {
      return await service.getDonorById(donorId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BloodDonor>> getDonorsNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      return await service.getDonorsNearby(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BloodDonor>> filterDonors({
    String? bloodGroup,
    String? gender,
    int? minAge,
    int? maxAge,
    bool? isAvailable,
  }) async {
    try {
      return await service.filterDonors(
        bloodGroup: bloodGroup,
        gender: gender,
        minAge: minAge,
        maxAge: maxAge,
        isAvailable: isAvailable,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BloodDonor>> getAllDonors() async {
    try {
      return await service.getAllDonors();
    } catch (e) {
      rethrow;
    }
  }
}
