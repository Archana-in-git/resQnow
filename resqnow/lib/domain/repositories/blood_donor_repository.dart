import 'package:resqnow/domain/entities/blood_donor.dart';

abstract class BloodDonorRepository {
  Future<void> registerDonor(BloodDonor donor);
  Future<void> updateDonor(BloodDonor donor);

  Future<BloodDonor?> getMyDonorProfile();
  Future<bool> isUserDonor();
  Future<BloodDonor?> getDonorById(String donorId);

  Future<List<BloodDonor>> getDonorsNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  Future<List<BloodDonor>> filterDonors({
    String? bloodGroup,
    String? gender,
    int? minAge,
    int? maxAge,
    bool? isAvailable,
  });

  Future<List<BloodDonor>> getAllDonors();
}
