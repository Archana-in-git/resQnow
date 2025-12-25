import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BloodDonor extends Equatable {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String bloodGroup;

  final String phone;
  final bool phoneVerified;

  /// Exact GPS location (optional)
  final GeoPoint? permanentLocation;

  /// Structured permanent address (existing)
  final Map<String, String> permanentAddress;

  /// 🔥 NEW — Extracted address fields for filtering
  final String? country;
  final String? state;
  final String? district;
  final String? town;
  final String? pincode;

  /// Full address composed string
  final String addressString;

  /// Last seen info
  final Map<String, dynamic>? lastSeen;

  final DateTime? lastDonationDate;
  final int totalDonations;
  final bool isAvailable;

  final List<String> medicalConditions;
  final String? notes;

  /// Profile picture URL
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

    this.permanentLocation,

    required this.permanentAddress,

    /// New structured fields
    this.country,
    this.state,
    this.district,
    this.town,
    this.pincode,

    required this.addressString,
    required this.lastSeen,

    this.lastDonationDate,
    this.totalDonations = 0,
    this.isAvailable = true,

    required this.medicalConditions,
    this.notes,
    this.profileImageUrl,

    required this.createdAt,
    required this.updatedAt,
  });

  // -----------------------------
  // copyWith
  // -----------------------------
  BloodDonor copyWith({
    String? name,
    int? age,
    String? gender,
    String? bloodGroup,
    String? phone,
    bool? phoneVerified,
    GeoPoint? permanentLocation,
    Map<String, String>? permanentAddress,

    String? country,
    String? state,
    String? district,
    String? town,
    String? pincode,

    String? addressString,
    Map<String, dynamic>? lastSeen,
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

      permanentLocation: permanentLocation ?? this.permanentLocation,
      permanentAddress: permanentAddress ?? this.permanentAddress,

      country: country ?? this.country,
      state: state ?? this.state,
      district: district ?? this.district,
      town: town ?? this.town,
      pincode: pincode ?? this.pincode,

      addressString: addressString ?? this.addressString,
      lastSeen: lastSeen ?? this.lastSeen,

      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      totalDonations: totalDonations ?? this.totalDonations,
      isAvailable: isAvailable ?? this.isAvailable,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      notes: notes ?? this.notes,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,

      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // -----------------------------
  // toMap
  // -----------------------------
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "age": age,
      "gender": gender,
      "bloodGroup": bloodGroup,
      "phone": phone,
      "phoneVerified": phoneVerified,

      "permanentLocation": permanentLocation,
      "permanentAddress": permanentAddress,

      /// new structured fields
      "country": country,
      "state": state,
      "district": district,
      "town": town,
      "pincode": pincode,

      "addressString": addressString,
      "lastSeen": lastSeen,
      "lastDonationDate": lastDonationDate != null
          ? Timestamp.fromDate(lastDonationDate!)
          : null,
      "totalDonations": totalDonations,
      "isAvailable": isAvailable,

      "medicalConditions": medicalConditions,
      "notes": notes,

      "profileImageUrl": profileImageUrl,

      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  // -----------------------------
  // Parse date helper
  // -----------------------------
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);

    try {
      if (value.toDate is Function) return value.toDate();
    } catch (_) {}

    return null;
  }

  // -----------------------------
  // fromMap
  // -----------------------------
  factory BloodDonor.fromMap(Map<String, dynamic> map) {
    final createdAtParsed = _parseDate(map["createdAt"]) ?? DateTime.now();
    final updatedAtParsed = _parseDate(map["updatedAt"]) ?? createdAtParsed;

    // Backward compatibility: extract town/district from permanentAddress if available
    final addr = Map<String, String>.from(map["permanentAddress"] ?? {});

    return BloodDonor(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      age: (map["age"] as num).toInt(),
      gender: map["gender"] ?? "",
      bloodGroup: map["bloodGroup"] ?? "",
      phone: map["phone"] ?? "",
      phoneVerified: map["phoneVerified"] ?? false,

      permanentLocation: map["permanentLocation"] as GeoPoint?,
      permanentAddress: addr,

      /// NEW — resolves missing fields gracefully
      country: map["country"] ?? addr["country"],
      state: map["state"] ?? addr["state"],
      district: map["district"] ?? addr["district"],
      town: map["town"] ?? addr["town"],
      pincode: (map["pincode"] ?? addr["pincode"])?.toString(),

      addressString: map["addressString"] ?? "",
      lastSeen: map['lastSeen'] as Map<String, dynamic>?,
      lastDonationDate: map['lastDonationDate'] != null
          ? (map['lastDonationDate'] as Timestamp).toDate()
          : null,
      totalDonations: (map["totalDonations"] ?? 0) as int,
      isAvailable: map["isAvailable"] ?? true,

      medicalConditions: List<String>.from(map["medicalConditions"] ?? []),
      notes: map["notes"],
      profileImageUrl: map["profileImageUrl"] as String?,

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
    permanentLocation,
    permanentAddress,
    country,
    state,
    district,
    town,
    pincode,
    addressString,
    lastSeen,
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
