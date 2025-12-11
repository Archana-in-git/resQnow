import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/repositories/blood_donor_repository.dart';

class GetDonorById {
  final BloodDonorRepository repository;

  GetDonorById(this.repository);

  Future<BloodDonor?> call(String id) {
    return repository.getDonorById(id);
  }
}
