// category_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resqnow/domain/entities/category.dart';
import 'package:resqnow/features/condition_categories/data/models/category_model.dart';

class CategoryService {
  final _categoryCollection = FirebaseFirestore.instance.collection(
    'categories',
  );
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<List<Category>> getVisibleCategories() async {
    try {
      final querySnapshot = await _categoryCollection
          .where('isVisible', isEqualTo: true)
          .orderBy('order')
          .get();

      return querySnapshot.docs.map((doc) {
        final model = CategoryModel.fromMap(doc.data(), doc.id);
        return model.toEntity();
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Log a category search query to Firestore for dashboard analytics
  /// This enables real-time tracking of most searched medical conditions/categories
  Future<void> logSearchQuery(String query, {String? categoryId}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No authenticated user for search logging');
        return;
      }

      // Don't log empty queries
      if (query.trim().isEmpty) {
        return;
      }

      // Add search log document
      await _firestore.collection('search_logs').add({
        'userId': currentUser.uid,
        'userEmail': currentUser.email,
        'query': query.toLowerCase().trim(),
        'categoryId': categoryId, // ID of the matched category if any
        'timestamp': DateTime.now().toIso8601String(),
        'appSection': 'category_search', // identifies where search came from
        'resultCount': 0, // will be updated by calling function if needed
      });

      print('✅ Search query logged: "$query"');
    } catch (e) {
      print('❌ Error logging search query: $e');
      // Don't throw - we don't want logging to break the search functionality
    }
  }

  /// Update search log with result count after searching
  Future<void> updateSearchResultCount(String query, int resultCount) async {
    try {
      final hour = DateTime.now();
      final startOfHour = DateTime(
        hour.year,
        hour.month,
        hour.day,
        hour.hour,
      ).toIso8601String();
      final endOfHour = DateTime(
        hour.year,
        hour.month,
        hour.day,
        hour.hour + 1,
      ).toIso8601String();

      // Find and update the most recent search log for this query in this hour
      final snapshot = await _firestore
          .collection('search_logs')
          .where('query', isEqualTo: query.toLowerCase().trim())
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: startOfHour,
            isLessThan: endOfHour,
          )
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'resultCount': resultCount,
        });
      }
    } catch (e) {
      print('Error updating search result count: $e');
    }
  }
}
