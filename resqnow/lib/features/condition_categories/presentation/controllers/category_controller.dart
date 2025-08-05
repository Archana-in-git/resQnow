// category_controller.dart

import 'package:flutter/material.dart';
import 'package:resqnow/domain/entities/category.dart';
import 'package:resqnow/features/condition_categories/data/services/category_service.dart';

class CategoryController extends ChangeNotifier {
  final CategoryService _categoryService;

  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CategoryController(this._categoryService);

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _categoryService.getVisibleCategories();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
