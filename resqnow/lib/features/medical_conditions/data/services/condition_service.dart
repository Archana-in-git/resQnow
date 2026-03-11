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
  /// Handles 3 linking strategies - runs queries in parallel for faster initialization:
  /// 1. New format: categories array field contains categoryId
  /// 2. Old format: categoryId field equals categoryId
  /// 3. 1-to-1 ID match: condition document ID equals categoryId
  Future<List<ConditionModel>> getConditionsByCategory(
    String categoryId,
  ) async {
    try {
      // Run all 3 queries in parallel instead of sequentially
      // This ensures Firestore connection is warmed up faster on cold-start
      final futures = await Future.wait([
        _firestore
            .collection('medical_conditions')
            .where('categories', arrayContains: categoryId)
            .get(),
        _firestore
            .collection('medical_conditions')
            .where('categoryId', isEqualTo: categoryId)
            .get(),
        _firestore
            .collection('medical_conditions')
            .doc(categoryId)
            .get()
            .catchError((_) => null as dynamic), // Silent error for ID match
      ], eagerError: false);

      final allDocs = <String, DocumentSnapshot>{};

      // Add results from query 1 (categories array)
      if (futures[0] != null) {
        for (var doc in (futures[0] as QuerySnapshot).docs) {
          allDocs[doc.id] = doc;
        }
      }

      // Add results from query 2 (categoryId field)
      if (futures[1] != null) {
        for (var doc in (futures[1] as QuerySnapshot).docs) {
          allDocs[doc.id] = doc;
        }
      }

      // Add result from query 3 (1-to-1 ID match)
      if (futures[2] != null && (futures[2] as DocumentSnapshot).exists) {
        allDocs[(futures[2] as DocumentSnapshot).id] =
            futures[2] as DocumentSnapshot;
      }

      final results = allDocs.values
          .map((doc) => ConditionModel.fromFirestore(doc))
          .toList();

      return results;
    } catch (e) {
      throw Exception('Failed to fetch conditions by category: $e');
    }
  }

  /// ✅ SAFELY GET SINGLE MEDICAL CONDITION BY CATEGORYID (1-to-1 relationship)
  /// Returns the single medical condition linked to a category
  /// Returns null if no condition exists (in case of missing document)
  /// [categoryId] - The category ID to search for
  Future<ConditionModel?> getConditionByCategoryId(String categoryId) async {
    try {
      // Query: Single condition with 'categoryId' field (1-to-1 relationship)
      final snapshot = await _firestore
          .collection('medical_conditions')
          .where('categoryId', isEqualTo: categoryId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      return ConditionModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch condition for category $categoryId: $e');
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
    } catch (e) {
      // Logging operation failed, continue silently
    }
  }
}
