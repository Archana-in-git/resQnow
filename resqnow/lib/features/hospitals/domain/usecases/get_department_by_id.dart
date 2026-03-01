import '../entities/department_entity.dart';
import '../repositories/department_repository.dart';

class GetDepartmentById {
  final DepartmentRepository repository;

  GetDepartmentById(this.repository);

  Future<DepartmentEntity> call(String departmentId) {
    return repository.getDepartmentById(departmentId);
  }
}
