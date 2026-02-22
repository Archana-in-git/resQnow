// lib/features/blood_donor/data/services/blood_donor_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/data/models/call_request_model.dart';

class BloodDonorService {
  BloodDonorService({required this.firestore, required this.auth});

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CollectionReference<Map<String, dynamic>> get _donorRef =>
      firestore.collection('donors');

  CollectionReference<Map<String, dynamic>> get _callRequestsRef =>
      firestore.collection('call_requests');

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
  // DELETE DONOR
  // -------------------------------------------------------------------------
  Future<void> deleteDonor() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    await _donorRef.doc(uid).delete();
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

  // =========================================================================
  // ======================== CALL REQUEST OPERATIONS ========================
  // =========================================================================

  // -------------------------------------------------------------------------
  // SUBMIT CALL REQUEST
  // -------------------------------------------------------------------------
  /// Submit a call request from the current user to a donor
  /// Returns the ID of the created call request
  Future<String> submitCallRequest({
    required String donorId,
    required String donorName,
    required String donorPhone,
  }) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception('User must be authenticated to request a call');
    }

    // Create new call request document
    final callRequestRef = _callRequestsRef.doc();
    final requestId = callRequestRef.id;

    final callRequest = CallRequestModel(
      id: requestId,
      requesterId: currentUser.uid,
      requesterName: currentUser.displayName ?? 'Anonymous',
      requesterEmail: currentUser.email ?? 'no-email@example.com',
      requesterPhone: null, // Can be added if user provides it
      requesterProfileImage: currentUser.photoURL,
      donorId: donorId,
      donorName: donorName,
      donorPhone: donorPhone,
      requestedAt: DateTime.now(),
      status: 'pending',
    );

    await callRequestRef.set(callRequest.toMap());

    // Also store reference in user's call_requests subcollection for easy access
    await firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('call_requests')
        .doc(requestId)
        .set({
          'donorId': donorId,
          'donorName': donorName,
          'requestedAt': FieldValue.serverTimestamp(),
          'status': 'pending',
        });

    // Store reference in donor's incoming_call_requests subcollection
    await firestore
        .collection('donors')
        .doc(donorId)
        .collection('incoming_call_requests')
        .doc(requestId)
        .set({
          'requesterId': currentUser.uid,
          'requesterName': callRequest.requesterName,
          'requesterEmail': callRequest.requesterEmail,
          'requestedAt': FieldValue.serverTimestamp(),
          'status': 'pending',
        });

    return requestId;
  }

  // -------------------------------------------------------------------------
  // GET CALL REQUEST BY ID
  // -------------------------------------------------------------------------
  Future<CallRequestModel?> getCallRequest(String requestId) async {
    final doc = await _callRequestsRef.doc(requestId).get();
    if (!doc.exists) return null;

    return CallRequestModel.fromMap(doc.data() ?? {}, id: doc.id);
  }

  // -------------------------------------------------------------------------
  // GET USER'S CALL REQUESTS
  // -------------------------------------------------------------------------
  /// Get all call requests made by the current user
  Future<List<CallRequestModel>> getUserCallRequests() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) return [];

    final snapshot = await _callRequestsRef
        .where('requesterId', isEqualTo: currentUser.uid)
        .orderBy('requestedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CallRequestModel.fromSnapshot(doc))
        .toList();
  }

  // -------------------------------------------------------------------------
  // GET DONOR'S INCOMING CALL REQUESTS
  // -------------------------------------------------------------------------
  /// Get all call requests for a specific donor
  Future<List<CallRequestModel>> getDonorCallRequests(String donorId) async {
    final snapshot = await _callRequestsRef
        .where('donorId', isEqualTo: donorId)
        .orderBy('requestedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CallRequestModel.fromSnapshot(doc))
        .toList();
  }

  // -------------------------------------------------------------------------
  // GET PENDING CALL REQUESTS FOR DONOR
  // -------------------------------------------------------------------------
  /// Get pending call requests for a specific donor (for admin/donor view)
  Future<List<CallRequestModel>> getPendingCallRequests(String donorId) async {
    final snapshot = await _callRequestsRef
        .where('donorId', isEqualTo: donorId)
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CallRequestModel.fromSnapshot(doc))
        .toList();
  }

  // -------------------------------------------------------------------------
  // UPDATE CALL REQUEST STATUS
  // -------------------------------------------------------------------------
  /// Update the status of a call request (used by admin)
  Future<void> updateCallRequestStatus({
    required String requestId,
    required String newStatus, // 'approved', 'rejected', 'expired', etc.
    String? adminNotes,
    String? chatChannelId,
  }) async {
    final updateData = {
      'status': newStatus,
      'approvedAt': newStatus == 'approved'
          ? FieldValue.serverTimestamp()
          : null,
      if (adminNotes != null) 'adminNotes': adminNotes,
      if (chatChannelId != null) 'chatChannelId': chatChannelId,
    };

    // Remove null values
    updateData.removeWhere((key, value) => value == null);

    await _callRequestsRef.doc(requestId).update(updateData);
  }

  // -------------------------------------------------------------------------
  // DELETE CALL REQUEST
  // -------------------------------------------------------------------------
  Future<void> deleteCallRequest(String requestId) async {
    await _callRequestsRef.doc(requestId).delete();
  }
}
