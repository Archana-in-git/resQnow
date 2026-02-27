import 'package:flutter/material.dart';
import 'package:resqnow/domain/entities/resource.dart';
import 'package:resqnow/domain/usecases/get_featured_resources.dart';

class ResourceController extends ChangeNotifier {
  final GetFeaturedResources getFeaturedResourcesUseCase;

  ResourceController({required this.getFeaturedResourcesUseCase});

  // ---------------------------------------------------------
  // STATE
  // ---------------------------------------------------------
  List<Resource> _allResources = [];
  List<Resource> _filteredResources = [];
  final Set<String> _activeCategories = <String>{};
  String _searchQuery = '';

  List<Resource> get resources => List.unmodifiable(_filteredResources);
  List<Resource> get allResources => List.unmodifiable(_allResources);
  Set<String> get activeCategories => Set.unmodifiable(_activeCategories);
  List<String> get availableCategories {
    final values = <String>{};
    for (final resource in _allResources) {
      values.addAll(resource.category);
    }
    final sorted = values.toList();
    sorted.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ---------------------------------------------------------
  // FETCH
  // ---------------------------------------------------------
  Future<void> fetchResources() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allResources = await getFeaturedResourcesUseCase.call();
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------
  void searchResources(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // ---------------------------------------------------------
  // CLEAR SEARCH
  // ---------------------------------------------------------
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // ---------------------------------------------------------
  // CATEGORY FILTERS
  // ---------------------------------------------------------
  void toggleCategory(String category) {
    final normalized = category.toLowerCase();
    if (_activeCategories.any((c) => c.toLowerCase() == normalized)) {
      _activeCategories.removeWhere((c) => c.toLowerCase() == normalized);
    } else {
      _activeCategories.add(category);
    }
    _applyFilters();
    notifyListeners();
  }

  void clearCategoryFilters() {
    if (_activeCategories.isEmpty) return;
    _activeCategories.clear();
    _applyFilters();
    notifyListeners();
  }

  // ---------------------------------------------------------
  // INTERNAL FILTER PIPELINE
  // ---------------------------------------------------------
  void _applyFilters() {
    Iterable<Resource> working = _allResources;

    if (_searchQuery.isNotEmpty) {
      working = working.where((resource) {
        final name = resource.name.toLowerCase();
        final description = resource.description.toLowerCase();
        final tags = resource.tags.map((tag) => tag.toLowerCase());
        final categories = resource.category.map((cat) => cat.toLowerCase());

        final nameMatch = name.contains(_searchQuery);
        final descMatch = description.contains(_searchQuery);
        final tagMatch = tags.any((tag) => tag.contains(_searchQuery));
        final categoryMatch = categories.any(
          (cat) => cat.contains(_searchQuery),
        );

        return nameMatch || descMatch || tagMatch || categoryMatch;
      });
    }

    if (_activeCategories.isNotEmpty) {
      final normalizedFilters = _activeCategories
          .map((c) => c.toLowerCase())
          .toSet();
      working = working.where((resource) {
        final resourceCategories = resource.category.map(
          (cat) => cat.toLowerCase(),
        );
        return resourceCategories.any((cat) => normalizedFilters.contains(cat));
      });
    }

    _filteredResources = working.toList();
  }
}
