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
      print('🔍 Fetching categories from Firestore...');
      
      // Try the full query with isVisible filter and orderBy
      try {
        final querySnapshot = await _categoryCollection
            .where('isVisible', isEqualTo: true)
            .orderBy('order')
            .get();

        print('✅ Found ${querySnapshot.docs.length} visible categories');
        
        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.map((doc) {
            final model = CategoryModel.fromMap(doc.data(), doc.id);
            return model.toEntity();
          }).toList();
        }
      } on FirebaseException catch (e) {
        // If the query fails (likely due to missing composite index),
        // fall back to a simpler query
        print('⚠️ Query with isVisible+orderBy failed: ${e.message}');
        print('🔄 Trying fallback without orderBy...');
        
        final fallbackSnapshot = await _categoryCollection
            .where('isVisible', isEqualTo: true)
            .get();
        
        print('✅ Fallback: Found ${fallbackSnapshot.docs.length} visible categories');
        
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
      print('🔄 No visible categories found, fetching ALL categories...');
      return await _getAllCategoriesNoFilter();
      
    } catch (e) {
      print('❌ Error fetching categories: $e');
      // Final fallback: get all categories
      return await _getAllCategoriesNoFilter();
    }
  }

  /// Get ALL categories without any filtering - for debugging
  Future<List<Category>> _getAllCategoriesNoFilter() async {
    print('🔍 DEBUG: Fetching ALL categories from Firestore (no filter)...');
    try {
      final allSnapshot = await _categoryCollection.get();
      print('📊 DEBUG: Total categories in DB: ${allSnapshot.docs.length}');
      
      // Print each category's data for debugging
      for (var doc in allSnapshot.docs) {
        print('   - ${doc.id}: ${doc.data()}');
      }
      
      if (allSnapshot.docs.isEmpty) {
        print('⚠️ DEBUG: No categories found in Firestore at all!');
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
      print('❌ DEBUG error: $e');
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
          print('Migrated category: ${doc.id}');
        }
      }

      print('Migration complete: $updated categories updated');
      return updated;
    } catch (e) {
      print('Error migrating categories: $e');
      rethrow;
    }
  }
}
