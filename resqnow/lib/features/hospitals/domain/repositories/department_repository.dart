import '../entities/department_entity.dart';

abstract class DepartmentRepository {
  Future<DepartmentEntity> getDepartmentById(String departmentId);
}
