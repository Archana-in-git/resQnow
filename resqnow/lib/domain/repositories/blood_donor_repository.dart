import 'package:resqnow/domain/entities/blood_donor.dart';

abstract class BloodDonorRepository {
  Future<void> registerDonor(BloodDonor donor);
  Future<void> updateDonor(BloodDonor donor);
  Future<void> deleteDonor();

  Future<BloodDonor?> getMyDonorProfile();
  Future<bool> isUserDonor();
  Future<BloodDonor?> getDonorById(String donorId);

  // ---------------------------------------------------------------------------
  // OLD NEARBY SEARCH (radius based) — Kept for backward compatibility
  // ---------------------------------------------------------------------------
  @Deprecated(
    "GPS radius search is no longer used. Use district/town filters instead.",
  )
  Future<List<BloodDonor>> getDonorsNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  // ---------------------------------------------------------------------------
  // NEW NEARBY LOGIC — DISTRICT & TOWN BASED
  // ---------------------------------------------------------------------------

  /// Fetch all donors inside a district
  Future<List<BloodDonor>> getDonorsByDistrict(String district);

  /// Fetch donors inside a specific town within a district
  Future<List<BloodDonor>> getDonorsByTown({
    required String district,
    required String town,
  });

  // ---------------------------------------------------------------------------
  // FILTERING LOGIC (now supports district/town)
  // ---------------------------------------------------------------------------
  Future<List<BloodDonor>> filterDonors({
    String? bloodGroup,
    String? gender,
    int? minAge,
    int? maxAge,
    bool? isAvailable,

    /// NEW — allow filtering by district
    String? district,

    /// NEW — allow filtering by town
    String? town,
  });

  Future<List<BloodDonor>> getAllDonors();
}
