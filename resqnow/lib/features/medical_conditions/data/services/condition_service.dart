import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/condition_model.dart';

class ConditionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all conditions
  Future<List<ConditionModel>> getAllConditions() async {
    try {
      final snapshot = await _firestore.collection('conditions').get();
      return snapshot.docs
          .map((doc) => ConditionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch conditions: $e');
    }
  }

  /// Fetch single condition by ID
  Future<ConditionModel> getConditionById(String id) async {
    try {
      final doc = await _firestore.collection('conditions').doc(id).get();

      if (!doc.exists) {
        throw Exception('Condition not found');
      }

      return ConditionModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch condition: $e');
    }
  }
}
