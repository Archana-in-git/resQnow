import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/repositories/blood_donor_repository.dart';

class GetMyDonorProfile {
  final BloodDonorRepository repository;

  GetMyDonorProfile(this.repository);

  Future<BloodDonor?> call() {
    return repository.getMyDonorProfile();
  }
}
