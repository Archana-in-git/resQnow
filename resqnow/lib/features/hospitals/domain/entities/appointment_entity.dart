class AppointmentEntity {
  final String id;
  final String userId;
  final String hospitalId;
  final String doctorId;
  final String patientName;
  final String phone;
  final String description;
  final String preferredDate;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AppointmentEntity({
    required this.id,
    required this.userId,
    required this.hospitalId,
    required this.doctorId,
    required this.patientName,
    required this.phone,
    required this.description,
    required this.preferredDate,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });
}
