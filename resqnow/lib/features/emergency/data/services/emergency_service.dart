import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency_model.dart';

class EmergencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<EmergencyContact?> fetchUserEmergencyContact(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .doc('primary')
        .get();
    if (doc.exists) {
      return EmergencyContact.fromMap(doc.data()!);
    }
    return null;
  }
}
