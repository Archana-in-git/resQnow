import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/condition_model.dart';

class ConditionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  /// Fetch single condition by its `id` field in Firestore
  Future<ConditionModel> getConditionById(String id) async {
    try {
      final doc = await _firestore
          .collection('medical_conditions')
          .doc(id)
          .get();

      if (!doc.exists) {
        throw Exception('Condition not found for id: $id');
      }

      return ConditionModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch condition: $e');
    }
  }

  /// Fetch conditions by category ID
  Future<List<ConditionModel>> getConditionsByCategory(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection('medical_conditions')
          .where('categoryId', isEqualTo: categoryId)
          .get();
      
      return snapshot.docs
          .map((doc) => ConditionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch conditions by category: $e');
    }
  }

  /// Track condition search/view by condition name
  /// Useful for finding which conditions are most useful to users
  Future<void> logConditionInteraction({
    required String conditionId,
    required String conditionName,
    required String interactionType, // 'viewed', 'searched', 'shared'
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Log to search_logs collection (used for "Most Searched/Viewed" dashboard metric)
      await _firestore.collection('search_logs').add({
        'userId': currentUser.uid,
        'userEmail': currentUser.email,
        'query': conditionName.toLowerCase(),
        'conditionId': conditionId,
        'timestamp': DateTime.now().toIso8601String(),
        'appSection': 'condition_detail',
        'interactionType': interactionType,
      });

      print(
        '✅ Condition interaction logged: $conditionName ($interactionType)',
      );
    } catch (e) {
      print('❌ Error logging condition interaction: $e');
    }
  }
}
