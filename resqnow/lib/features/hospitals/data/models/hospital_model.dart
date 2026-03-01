// Data model for Hospital.
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/hospital_entity.dart';

class HospitalModel extends HospitalEntity {
  const HospitalModel({
    required String id,
    required String name,
    required String address,
    required String phone,
    required String email,
    required String status,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super(
         id: id,
         name: name,
         address: address,
         phone: phone,
         email: email,
         status: status,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  factory HospitalModel.fromJson(Map<String, dynamic> json, String docId) {
    return HospitalModel(
      id: docId,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      status: json['status'] as String,
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] == null
          ? null
          : (json['updatedAt'] is Timestamp)
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
