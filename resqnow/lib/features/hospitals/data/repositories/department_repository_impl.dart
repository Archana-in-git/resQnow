import '../../domain/entities/department_entity.dart';
import '../../domain/repositories/department_repository.dart';
import '../datasources/department_remote_datasource.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final DepartmentRemoteDatasource remoteDatasource;

  DepartmentRepositoryImpl({required this.remoteDatasource});

  @override
  Future<DepartmentEntity> getDepartmentById(String departmentId) {
    return remoteDatasource.getDepartmentById(departmentId);
  }
}
