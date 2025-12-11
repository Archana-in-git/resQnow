// lib/domain/usecases/get_donors.dart
import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/repositories/blood_donor_repository.dart';

class GetDonorsNearby {
  final BloodDonorRepository repository;

  GetDonorsNearby(this.repository);

  Future<List<BloodDonor>> call({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) {
    return repository.getDonorsNearby(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }
}
