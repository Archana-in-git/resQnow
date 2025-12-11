// lib/features/blood_donor/data/services/blood_donor_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';

// This class is a concrete Firestore service (NOT the repository).
// The repository implementation (data/repositories/...) will call this service.
// Keep Firestore specifics here (Timestamp handling, FieldValue, etc).
class BloodDonorService {
  BloodDonorService({required this.firestore, required this.auth});

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CollectionReference<Map<String, dynamic>> get _donorRef =>
      firestore.collection('donors');

  Future<void> registerDonor(BloodDonor donor) async {
    final map = donor.toMap();
    // Prefer server timestamp for createdAt/updatedAt
    map['createdAt'] = FieldValue.serverTimestamp();
    map['updatedAt'] = FieldValue.serverTimestamp();
    await _donorRef.doc(donor.id).set(map, SetOptions(merge: true));
  }

  Future<void> updateDonor(BloodDonor donor) async {
    final map = donor.toMap();
    map['updatedAt'] = FieldValue.serverTimestamp();
    await _donorRef.doc(donor.id).update(map);
  }

  Future<BloodDonor?> getMyDonorProfile() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _donorRef.doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    // Ensure doc id is present in map for fromMap
    data['id'] = doc.id;
    return BloodDonor.fromMap(data);
  }

  Future<bool> isUserDonor() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return false;
    return (await _donorRef.doc(uid).get()).exists;
  }

  Future<BloodDonor?> getDonorById(String donorId) async {
    final doc = await _donorRef.doc(donorId).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return BloodDonor.fromMap(data);
  }

  Future<List<BloodDonor>> getDonorsNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    final snapshot = await _donorRef
        .where('isAvailable', isEqualTo: true)
        .get();

    final List<BloodDonor> results = [];

    for (final doc in snapshot.docs) {
      final donor = BloodDonor.fromMap({...doc.data(), 'id': doc.id});

      if (donor.latitude == null || donor.longitude == null) continue;

      final distance = _distanceKm(
        latitude,
        longitude,
        donor.latitude!,
        donor.longitude!,
      );

      if (distance <= radiusKm) {
        results.add(donor);
      }
    }

    return results;
  }

  Future<List<BloodDonor>> filterDonors({
    String? bloodGroup,
    String? gender,
    int? minAge,
    int? maxAge,
    bool? isAvailable,
  }) async {
    Query<Map<String, dynamic>> query = _donorRef;

    if (bloodGroup != null && bloodGroup.isNotEmpty) {
      query = query.where('bloodGroup', isEqualTo: bloodGroup);
    }
    if (gender != null && gender.isNotEmpty) {
      query = query.where('gender', isEqualTo: gender);
    }
    if (isAvailable != null) {
      query = query.where('isAvailable', isEqualTo: isAvailable);
    }

    final snapshot = await query.get();
    final donors = snapshot.docs
        .map((doc) => BloodDonor.fromMap({...doc.data(), 'id': doc.id}))
        .toList();

    return donors.where((donor) {
      final age = donor.age;
      final meetsMin = minAge == null || age >= minAge;
      final meetsMax = maxAge == null || age <= maxAge;
      return meetsMin && meetsMax;
    }).toList();
  }

  Future<List<BloodDonor>> getAllDonors() async {
    final snapshot = await _donorRef.get();
    return snapshot.docs
        .map((doc) => BloodDonor.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  double _distanceKm(
    double originLat,
    double originLng,
    double targetLat,
    double targetLng,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degToRad(targetLat - originLat);
    final dLng = _degToRad(targetLng - originLng);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(originLat)) *
            cos(_degToRad(targetLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double degrees) => degrees * (pi / 180.0);
}
