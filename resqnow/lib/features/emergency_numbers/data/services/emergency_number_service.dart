import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqnow/data/models/emergency_number_model.dart';

class EmergencyNumberService {
  final CollectionReference _emergencyCollection = FirebaseFirestore.instance
      .collection('emergency_numbers');

  // Fetch all emergency numbers
  Future<List<EmergencyNumberModel>> fetchEmergencyNumbers() async {
    try {
      final snapshot = await _emergencyCollection.get();
      return snapshot.docs
          .map((doc) => EmergencyNumberModel.fromDoc(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch emergency numbers: $e');
    }
  }

  // Add a new emergency number
  Future<void> addEmergencyNumber(EmergencyNumberModel number) async {
    try {
      await _emergencyCollection.add(number.toMap());
    } catch (e) {
      throw Exception('Failed to add emergency number: $e');
    }
  }

  // Update an existing emergency number
  Future<void> updateEmergencyNumber(EmergencyNumberModel number) async {
    try {
      await _emergencyCollection.doc(number.id).update(number.toMap());
    } catch (e) {
      throw Exception('Failed to update emergency number: $e');
    }
  }

  // Delete an emergency number
  Future<void> deleteEmergencyNumber(String id) async {
    try {
      await _emergencyCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete emergency number: $e');
    }
  }
}
