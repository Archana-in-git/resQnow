import 'package:flutter/foundation.dart';
import '../../data/models/condition_model.dart';
import '../../data/services/condition_service.dart';

class ConditionController extends ChangeNotifier {
  final ConditionService _conditionService = ConditionService();

  final ValueNotifier<ConditionModel?> condition = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  /// Fetch a condition by its `id` field in Firestore
  Future<void> fetchCondition(String id) async {
    isLoading.value = true;
    errorMessage.value = null;
    condition.value = null; // clear old data

    try {
      final fetchedCondition = await _conditionService.getConditionById(id);
      condition.value = fetchedCondition;

      // 📊 Track this view for analytics (High Severity Cases Viewed)
      await _conditionService.incrementConditionViewCount(id);
    } catch (e) {
      errorMessage.value = 'Error fetching condition: $e';
      condition.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset controller state
  void clear() {
    condition.value = null;
    errorMessage.value = null;
    isLoading.value = false;
  }
}
