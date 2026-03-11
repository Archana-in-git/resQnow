import '../../domain/entities/doctor_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.id,
    required super.name,
    required super.hospitalId,
    required super.departmentName,
    required super.experienceYears,
    required super.consultationStart,
    required super.consultationEnd,
    required super.isAvailable,
    required super.createdAt,
    super.updatedAt,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json, String docId) {
    return DoctorModel(
      id: docId,
      name: json['name'] ?? '',
      hospitalId: json['hospitalId'] ?? '',
      departmentName: json['department'] ?? json['departmentName'] ?? '',
      experienceYears: (json['experienceYears'] ?? 0) is int
          ? json['experienceYears']
          : int.tryParse(json['experienceYears'].toString()) ?? 0,
      consultationStart: json['consultationStart'] ?? '',
      consultationEnd: json['consultationEnd'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
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
      'name': name,
      'hospitalId': hospitalId,
      'department': departmentName,
      'experienceYears': experienceYears,
      'consultationStart': consultationStart,
      'consultationEnd': consultationEnd,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
