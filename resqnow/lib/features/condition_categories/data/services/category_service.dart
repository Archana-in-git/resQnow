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
      // Try the full query with isVisible filter and orderBy
      try {
        final querySnapshot = await _categoryCollection
            .where('isVisible', isEqualTo: true)
            .orderBy('order')
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.map((doc) {
            final model = CategoryModel.fromMap(doc.data(), doc.id);
            return model.toEntity();
          }).toList();
        }
      } on FirebaseException catch (_) {
        // If the query fails (likely due to missing composite index),
        // fall back to a simpler query
        final fallbackSnapshot = await _categoryCollection
            .where('isVisible', isEqualTo: true)
            .get();

        if (fallbackSnapshot.docs.isNotEmpty) {
          final categories = fallbackSnapshot.docs.map((doc) {
            final model = CategoryModel.fromMap(doc.data(), doc.id);
            return model.toEntity();
          }).toList();

          // Sort by order
          categories.sort((a, b) => a.order.compareTo(b.order));
          return categories;
        }
      }

      // If still no results, try getting ALL categories
      return await _getAllCategoriesNoFilter();
    } catch (e) {
      // Final fallback: get all categories
      return await _getAllCategoriesNoFilter();
    }
  }

  /// Get ALL categories without any filtering
  Future<List<Category>> _getAllCategoriesNoFilter() async {
    try {
      final allSnapshot = await _categoryCollection.get();

      if (allSnapshot.docs.isEmpty) {
        return [];
      }

      final categories = allSnapshot.docs.map((doc) {
        final model = CategoryModel.fromMap(doc.data(), doc.id);
        return model.toEntity();
      }).toList();

      // Sort by order
      categories.sort((a, b) => a.order.compareTo(b.order));
      return categories;
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
    } catch (e) {
      // Silently fail - we don't want logging to break the search functionality
    }
  }

  /// Update search log with result count after searching
  Future<void> updateSearchResultCount(String query, int resultCount) async {
    try {
      // Log search entry (write-only, no read queries to avoid permission issues)
      await _firestore.collection('search_logs').add({
        'query': query.toLowerCase().trim(),
        'resultCount': resultCount,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silently fail - search logging should not block user operations
    }
  }

  /// Migrate existing categories to ensure they have required fields
  /// This fixes categories that may be missing isVisible or order fields
  Future<int> migrateCategories() async {
    try {
      final snapshot = await _categoryCollection.get();
      int updated = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        bool needsUpdate = false;
        Map<String, dynamic> updates = {};

        // Ensure isVisible field exists
        if (!data.containsKey('isVisible')) {
          updates['isVisible'] = true;
          needsUpdate = true;
        }

        // Ensure order field exists
        if (!data.containsKey('order')) {
          // Use document index as order if not set
          updates['order'] = snapshot.docs.indexOf(doc) + 1;
          needsUpdate = true;
        }

        if (needsUpdate) {
          await doc.reference.update(updates);
          updated++;
        }
      }

      return updated;
    } catch (e) {
      rethrow;
    }
  }
}
