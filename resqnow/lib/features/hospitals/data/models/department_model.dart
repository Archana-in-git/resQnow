import '../../domain/entities/department_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel extends DepartmentEntity {
  const DepartmentModel({
    required super.id,
    required super.name,
    required super.createdAt,
    super.updatedAt,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json, String docId) {
    return DepartmentModel(
      id: docId,
      name: json['name'] ?? '',
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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
