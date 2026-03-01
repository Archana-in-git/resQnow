class DepartmentEntity {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DepartmentEntity({
    required this.id,
    required this.name,
    required this.createdAt,
    this.updatedAt,
  });
}
