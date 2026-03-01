class DoctorEntity {
  final String id;
  final String name;
  final String hospitalId;
  final String departmentName;
  final int experienceYears;
  final String consultationStart;
  final String consultationEnd;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DoctorEntity({
    required this.id,
    required this.name,
    required this.hospitalId,
    required this.departmentName,
    required this.experienceYears,
    required this.consultationStart,
    required this.consultationEnd,
    required this.isAvailable,
    required this.createdAt,
    this.updatedAt,
  });
}
