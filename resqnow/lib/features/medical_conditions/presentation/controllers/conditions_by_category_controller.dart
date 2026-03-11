import 'package:flutter/foundation.dart';
import '../../data/models/condition_model.dart';
import '../../data/services/condition_service.dart';

class ConditionsByCategoryController extends ChangeNotifier {
  final ConditionService _conditionService = ConditionService();

  List<ConditionModel> _conditions = [];
  bool _isLoading = false;
  String? _error;
  String? _categoryId;
  String? _categoryName;

  List<ConditionModel> get conditions => _conditions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get categoryId => _categoryId;
  String? get categoryName => _categoryName;

  /// Fetch conditions for a specific category
  Future<void> fetchConditionsByCategory(
    String categoryId,
    String categoryName,
  ) async {
    _isLoading = true;
    _error = null;
    _categoryId = categoryId;
    _categoryName = categoryName;
    notifyListeners();

    try {
      _conditions = await _conditionService.getConditionsByCategory(categoryId);
    } catch (e) {
      _error = e.toString();
      _conditions = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear the controller state
  void clear() {
    _conditions = [];
    _isLoading = false;
    _error = null;
    _categoryId = null;
    _categoryName = null;
    notifyListeners();
  }

  /// Reset for a new category
  void reset() {
    clear();
  }
}
