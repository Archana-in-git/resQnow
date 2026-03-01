import '../../domain/repositories/hospital_repository.dart';
import '../../domain/entities/hospital_entity.dart';
import '../datasources/hospital_remote_datasource.dart';

class HospitalRepositoryImpl implements HospitalRepository {
  final HospitalRemoteDatasource remoteDatasource;

  HospitalRepositoryImpl({required this.remoteDatasource});

  @override
  Stream<List<HospitalEntity>> getApprovedHospitals() {
    return remoteDatasource.getApprovedHospitals();
  }
}
