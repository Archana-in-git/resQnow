import '../../domain/entities/appointment_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required String id,
    required String userId,
    required String hospitalId,
    required String doctorId,
    required String patientName,
    required String phone,
    required String description,
    required String preferredDate,
    required String status,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super(
         id: id,
         userId: userId,
         hospitalId: hospitalId,
         doctorId: doctorId,
         patientName: patientName,
         phone: phone,
         description: description,
         preferredDate: preferredDate,
         status: status,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  factory AppointmentModel.fromJson(Map<String, dynamic> json, String docId) {
    return AppointmentModel(
      id: docId,
      userId: json['userId'] ?? '',
      hospitalId: json['hospitalId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      patientName: json['patientName'] ?? '',
      phone: json['phone'] ?? '',
      description: json['description'] ?? '',
      preferredDate: json['preferredDate'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? _toDateTime(json['updatedAt'])
          : null,
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime(1970);
    return DateTime(1970);
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'hospitalId': hospitalId,
      'doctorId': doctorId,
      'patientName': patientName,
      'phone': phone,
      'description': description,
      'preferredDate': preferredDate,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
