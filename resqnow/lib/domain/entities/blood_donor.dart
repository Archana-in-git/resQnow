// lib/domain/entities/blood_donor.dart
import 'package:equatable/equatable.dart';

// NOTE: avoid importing cloud_firestore in domain layer if you prefer,
// but _parseDate will still try to handle common representations.
class BloodDonor extends Equatable {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String bloodGroup;

  final String phone;
  final bool phoneVerified;

  final double? latitude;
  final double? longitude;
  final String address;

  final DateTime? lastDonationDate;
  final int totalDonations;
  final bool isAvailable;

  final List<String> medicalConditions;
  final String? notes;

  final String? profileImageUrl;

  final DateTime createdAt;
  final DateTime updatedAt;

  const BloodDonor({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.phone,
    required this.phoneVerified,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.lastDonationDate,
    required this.totalDonations,
    required this.isAvailable,
    required this.medicalConditions,
    this.notes,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  BloodDonor copyWith({
    String? name,
    int? age,
    String? gender,
    String? bloodGroup,
    String? phone,
    bool? phoneVerified,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? lastDonationDate,
    int? totalDonations,
    bool? isAvailable,
    List<String>? medicalConditions,
    String? notes,
    String? profileImageUrl,
    DateTime? updatedAt,
  }) {
    return BloodDonor(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      totalDonations: totalDonations ?? this.totalDonations,
      isAvailable: isAvailable ?? this.isAvailable,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      notes: notes ?? this.notes,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'phone': phone,
      'phoneVerified': phoneVerified,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'lastDonationDate': lastDonationDate?.toIso8601String(),
      'totalDonations': totalDonations,
      'isAvailable': isAvailable,
      'medicalConditions': medicalConditions,
      'notes': notes,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    if (value is int) {
      // assume milliseconds
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (_) {
        return null;
      }
    }
    // try to handle Firestore Timestamp without importing it explicitly
    try {
      // `value.toDate()` will work for Timestamp at runtime
      final dynamic maybeTimestamp = value;
      if (maybeTimestamp != null && maybeTimestamp.toDate is Function) {
        return maybeTimestamp.toDate();
      }
    } catch (_) {}
    return null;
  }

  factory BloodDonor.fromMap(Map<String, dynamic> map) {
    final createdAtParsed = _parseDate(map['createdAt']) ?? DateTime.now();
    final updatedAtParsed = _parseDate(map['updatedAt']) ?? createdAtParsed;

    return BloodDonor(
      id: (map['id'] ?? map['docId'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      age: ((map['age'] is num)
          ? (map['age'] as num).toInt()
          : int.tryParse('${map['age']}') ?? 0),
      gender: (map['gender'] ?? '') as String,
      bloodGroup: (map['bloodGroup'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      phoneVerified: map['phoneVerified'] ?? false,
      latitude: map['latitude'] != null
          ? (map['latitude'] as num).toDouble()
          : null,
      longitude: map['longitude'] != null
          ? (map['longitude'] as num).toDouble()
          : null,
      address: (map['address'] ?? '') as String,
      lastDonationDate: _parseDate(map['lastDonationDate']),
      totalDonations: (map['totalDonations'] is num)
          ? (map['totalDonations'] as num).toInt()
          : (int.tryParse('${map['totalDonations']}') ?? 0),
      isAvailable: map['isAvailable'] ?? true,
      medicalConditions: List<String>.from(map['medicalConditions'] ?? []),
      notes: map['notes'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: createdAtParsed,
      updatedAt: updatedAtParsed,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    age,
    gender,
    bloodGroup,
    phone,
    phoneVerified,
    latitude,
    longitude,
    address,
    lastDonationDate,
    totalDonations,
    isAvailable,
    medicalConditions,
    notes,
    profileImageUrl,
    createdAt,
    updatedAt,
  ];
}
