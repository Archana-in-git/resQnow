// lib/features/blood_donor/data/services/blood_donor_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';

class BloodDonorService {
  BloodDonorService({required this.firestore, required this.auth});

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CollectionReference<Map<String, dynamic>> get _donorRef =>
      firestore.collection('donors');

  // -------------------------------------------------------------------------
  // REGISTER DONOR
  // -------------------------------------------------------------------------
  Future<void> registerDonor(BloodDonor donor) async {
    final map = donor.toMap();

    map['createdAt'] = FieldValue.serverTimestamp();
    map['updatedAt'] = FieldValue.serverTimestamp();

    await _donorRef.doc(donor.id).set(map, SetOptions(merge: true));
  }

  // -------------------------------------------------------------------------
  // UPDATE DONOR
  // -------------------------------------------------------------------------
  Future<void> updateDonor(BloodDonor donor) async {
    final map = donor.toMap();

    map['updatedAt'] = FieldValue.serverTimestamp();

    await _donorRef.doc(donor.id).update(map);
  }

  // -------------------------------------------------------------------------
  // GET MY PROFILE
  // -------------------------------------------------------------------------
  Future<BloodDonor?> getMyDonorProfile() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _donorRef.doc(uid).get();
    if (!doc.exists) return null;

    return BloodDonor.fromMap({...doc.data()!, "id": doc.id});
  }

  // -------------------------------------------------------------------------
  // CHECK IF USER IS DONOR
  // -------------------------------------------------------------------------
  Future<bool> isUserDonor() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return false;

    return (await _donorRef.doc(uid).get()).exists;
  }

  // -------------------------------------------------------------------------
  // GET DONOR BY ID
  // -------------------------------------------------------------------------
  Future<BloodDonor?> getDonorById(String donorId) async {
    final doc = await _donorRef.doc(donorId).get();
    if (!doc.exists) return null;

    return BloodDonor.fromMap({...doc.data()!, "id": doc.id});
  }

  // -------------------------------------------------------------------------
  // 🔥 NEW: GET DONORS BY DISTRICT
  // -------------------------------------------------------------------------
  Future<List<BloodDonor>> getDonorsByDistrict(String district) async {
    // district is stored in donor.district
    final snapshot = await _donorRef
        .where("district", isEqualTo: district)
        .where("isAvailable", isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => BloodDonor.fromMap({...doc.data(), "id": doc.id}))
        .toList();
  }

  // -------------------------------------------------------------------------
  // 🔥 NEW: GET DONORS BY TOWN (within a district)
  // -------------------------------------------------------------------------
  Future<List<BloodDonor>> getDonorsByTown({
    required String district,
    required String town,
  }) async {
    final snapshot = await _donorRef
        .where("district", isEqualTo: district)
        .where("town", isEqualTo: town)
        .where("isAvailable", isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => BloodDonor.fromMap({...doc.data(), "id": doc.id}))
        .toList();
  }

  // -------------------------------------------------------------------------
  // ❌ DEPRECATED — GPS NEARBY SEARCH (no longer used)
  // -------------------------------------------------------------------------
  @Deprecated("Use getDonorsByDistrict() and getDonorsByTown() instead.")
  Future<List<BloodDonor>> getDonorsNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    return []; // intentionally disabled
  }

  // -------------------------------------------------------------------------
  // FILTER DONORS — UPDATED WITH DISTRICT & TOWN SUPPORT
  // -------------------------------------------------------------------------
  Future<List<BloodDonor>> filterDonors({
    String? bloodGroup,
    String? gender,
    int? minAge,
    int? maxAge,
    bool? isAvailable,

    String? district,
    String? town,
  }) async {
    Query<Map<String, dynamic>> query = _donorRef;

    // 🔥 address-based filtering
    if (district != null && district.isNotEmpty) {
      query = query.where("district", isEqualTo: district);
    }
    if (town != null && town.isNotEmpty) {
      query = query.where("town", isEqualTo: town);
    }

    // blood, gender, availability
    if (bloodGroup != null && bloodGroup.isNotEmpty) {
      query = query.where("bloodGroup", isEqualTo: bloodGroup);
    }
    if (gender != null && gender.isNotEmpty) {
      query = query.where("gender", isEqualTo: gender);
    }
    if (isAvailable != null) {
      query = query.where("isAvailable", isEqualTo: isAvailable);
    }

    final snapshot = await query.get();

    final donors = snapshot.docs
        .map((doc) => BloodDonor.fromMap({...doc.data(), "id": doc.id}))
        .toList();

    // Age filtering (client-side)
    return donors.where((d) {
      final meetsMin = minAge == null || d.age >= minAge;
      final meetsMax = maxAge == null || d.age <= maxAge;
      return meetsMin && meetsMax;
    }).toList();
  }

  // -------------------------------------------------------------------------
  // GET ALL DONORS
  // -------------------------------------------------------------------------
  Future<List<BloodDonor>> getAllDonors() async {
    final snapshot = await _donorRef.get();
    return snapshot.docs
        .map((doc) => BloodDonor.fromMap({...doc.data(), "id": doc.id}))
        .toList();
  }
}
