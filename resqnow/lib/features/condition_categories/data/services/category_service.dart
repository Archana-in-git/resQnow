// category_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqnow/domain/entities/category.dart';
import 'package:resqnow/features/condition_categories/data/models/category_model.dart';

class CategoryService {
  final _categoryCollection = FirebaseFirestore.instance.collection(
    'categories',
  );

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
}
