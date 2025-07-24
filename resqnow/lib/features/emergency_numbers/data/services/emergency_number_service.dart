import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqnow/data/models/emergency_contact_model.dart';

class EmergencyNumberService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'emergency_numbers';

  /// Fetch all emergency numbers
  Future<List<EmergencyContact>> fetchEmergencyNumbers() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => EmergencyContact.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load emergency numbers: $e');
    }
  }
}
