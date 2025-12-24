// lib/domain/usecases/get_all_donors.dart

import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/repositories/blood_donor_repository.dart';

/// Fetch all donors regardless of district/town
class GetAllDonors {
  final BloodDonorRepository repository;

  GetAllDonors(this.repository);

  Future<List<BloodDonor>> call() async {
    return await repository.getAllDonors();
  }
}
