import '../../domain/entities/doctor_entity.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../datasources/doctor_remote_datasource.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDatasource remoteDatasource;

  DoctorRepositoryImpl({required this.remoteDatasource});

  @override
  Stream<List<DoctorEntity>> getDoctorsByHospital(String hospitalId) {
    return remoteDatasource.getDoctorsByHospital(hospitalId);
  }
}
