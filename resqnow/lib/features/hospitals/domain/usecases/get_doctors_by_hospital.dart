import '../entities/doctor_entity.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorsByHospital {
  final DoctorRepository repository;

  GetDoctorsByHospital(this.repository);

  Stream<List<DoctorEntity>> call(String hospitalId) {
    return repository.getDoctorsByHospital(hospitalId);
  }
}
