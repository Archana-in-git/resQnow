// category_controller.dart

import 'package:flutter/material.dart';
import 'package:resqnow/domain/entities/category.dart';
import 'package:resqnow/features/condition_categories/data/services/category_service.dart';

class CategoryController extends ChangeNotifier {
  final CategoryService _categoryService;

  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _error;

  List<Category> get categories =>
      _isSearching ? _filteredCategories : _allCategories;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;

  CategoryController(this._categoryService);

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allCategories = await _categoryService.getVisibleCategories();
      _filteredCategories = _allCategories;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void searchCategories(String query) {
    if (query.isEmpty) {
      _isSearching = false;
      _filteredCategories = _allCategories;
    } else {
      _isSearching = true;
      final lowercaseQuery = query.toLowerCase();

      _filteredCategories = _allCategories.where((category) {
        // Search in category name
        if (category.name.toLowerCase().contains(lowercaseQuery)) {
          return true;
        }

        // Search in aliases
        return category.aliases.any(
          (alias) => alias.toLowerCase().contains(lowercaseQuery),
        );
      }).toList();

      // ✅ LOG SEARCH TO FIRESTORE FOR DASHBOARD ANALYTICS
      // This enables the "Most Searched Condition" card to show real data
      _logSearchToFirestore(query);
    }
    notifyListeners();
  }

  void clearSearch() {
    _isSearching = false;
    _filteredCategories = _allCategories;
    notifyListeners();
  }

  /// Private method to log search queries asynchronously
  /// Doesn't block the UI or search functionality
  void _logSearchToFirestore(String query) async {
    try {
      // Log the search query
      await _categoryService.logSearchQuery(query);

      // Update with result count
      await _categoryService.updateSearchResultCount(
        query,
        _filteredCategories.length,
      );
    } catch (e) {
      // Silently fail - logging errors shouldn't affect the user experience
      debugPrint('Error in search logging: $e');
    }
  }
}
