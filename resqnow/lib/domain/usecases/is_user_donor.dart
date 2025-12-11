import 'package:resqnow/domain/repositories/blood_donor_repository.dart';

class IsUserDonor {
  final BloodDonorRepository repository;

  IsUserDonor(this.repository);

  Future<bool> call() {
    return repository.isUserDonor();
  }
}
