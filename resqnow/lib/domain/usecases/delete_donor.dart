import 'package:resqnow/domain/repositories/blood_donor_repository.dart';

class DeleteDonor {
  final BloodDonorRepository repository;

  DeleteDonor(this.repository);

  Future<void> call() {
    return repository.deleteDonor();
  }
}
