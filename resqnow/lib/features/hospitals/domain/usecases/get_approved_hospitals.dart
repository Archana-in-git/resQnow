import '../entities/hospital_entity.dart';
import '../repositories/hospital_repository.dart';

class GetApprovedHospitals {
  final HospitalRepository repository;

  GetApprovedHospitals(this.repository);

  Stream<List<HospitalEntity>> call() {
    return repository.getApprovedHospitals();
  }
}
