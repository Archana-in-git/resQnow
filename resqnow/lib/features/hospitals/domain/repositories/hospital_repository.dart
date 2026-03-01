import '../entities/hospital_entity.dart';

abstract class HospitalRepository {
  Stream<List<HospitalEntity>> getApprovedHospitals();
}
