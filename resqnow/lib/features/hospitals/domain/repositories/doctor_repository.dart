import '../entities/doctor_entity.dart';

abstract class DoctorRepository {
  Stream<List<DoctorEntity>> getDoctorsByHospital(String hospitalId);
}
