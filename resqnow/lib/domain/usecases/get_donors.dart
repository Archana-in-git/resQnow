// lib/domain/usecases/get_donors.dart

import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/repositories/blood_donor_repository.dart';

/// Fetch all donors inside a specific district
class GetDonorsByDistrict {
  final BloodDonorRepository repository;

  GetDonorsByDistrict(this.repository);

  Future<List<BloodDonor>> call(String district) {
    return repository.getDonorsByDistrict(district);
  }
}

/// Fetch donors inside a specific town in a district
class GetDonorsByTown {
  final BloodDonorRepository repository;

  GetDonorsByTown(this.repository);

  Future<List<BloodDonor>> call({
    required String district,
    required String town,
  }) {
    return repository.getDonorsByTown(district: district, town: town);
  }
}
