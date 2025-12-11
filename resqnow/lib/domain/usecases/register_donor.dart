// lib/domain/usecases/register_donor.dart

import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/repositories/blood_donor_repository.dart';

class RegisterDonor {
  final BloodDonorRepository repository;

  RegisterDonor(this.repository);

  Future<void> call(BloodDonor donor) {
    return repository.registerDonor(donor);
  }
}
