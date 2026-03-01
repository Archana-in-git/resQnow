// Core entity representing a Hospital.

class HospitalEntity {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const HospitalEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });
}
