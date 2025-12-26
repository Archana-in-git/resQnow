import 'package:flutter/material.dart';
import '../../data/models/saved_condition_model.dart';
import '../../data/services/saved_topics_service.dart';

class SavedController extends ChangeNotifier {
  final SavedTopicsService _service = SavedTopicsService();

  List<SavedConditionModel> _savedConditions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SavedConditionModel> get savedConditions => _savedConditions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all saved conditions from database
  Future<void> loadSavedConditions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _savedConditions = await _service.getSavedConditions();
      _error = null;
    } catch (e) {
      _error = 'Failed to load saved conditions: $e';
      _savedConditions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save a condition
  Future<void> saveCondition(SavedConditionModel condition) async {
    try {
      await _service.saveCondition(condition);
      // Reload conditions to reflect changes
      await loadSavedConditions();
    } catch (e) {
      _error = 'Failed to save condition: $e';
      notifyListeners();
    }
  }

  /// Delete a saved condition
  Future<void> deleteCondition(String conditionId) async {
    try {
      await _service.deleteCondition(conditionId);
      _savedConditions.removeWhere((condition) => condition.id == conditionId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete condition: $e';
      notifyListeners();
    }
  }

  /// Check if a condition is saved
  Future<bool> isConditionSaved(String conditionId) async {
    try {
      return await _service.isConditionSaved(conditionId);
    } catch (e) {
      return false;
    }
  }

  /// Clear all saved conditions
  Future<void> clearAllConditions() async {
    try {
      await _service.clearAllConditions();
      _savedConditions = [];
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear conditions: $e';
      notifyListeners();
    }
  }
}
