import 'package:get/get.dart';
import '../../data/models/condition_model.dart';
import '../../data/services/condition_service.dart';

class ConditionController extends GetxController {
  final ConditionService _conditionService = ConditionService();

  final Rx<ConditionModel?> _condition = Rx<ConditionModel?>(null);
  Rx<ConditionModel?> get condition => _condition;

  final RxBool _isLoading = false.obs;
  RxBool get isLoading => _isLoading;

  final RxnString _errorMessage = RxnString();
  RxnString get errorMessage => _errorMessage;

  /// Fetch a condition by its `id` field in Firestore
  Future<void> fetchCondition(String id) async {
    _isLoading.value = true;
    _errorMessage.value = null;
    _condition.value = null; // ensure old data is cleared

    try {
      final fetchedCondition = await _conditionService.getConditionById(id);
      _condition.value = fetchedCondition;
    } catch (e) {
      // Store a user-friendly error message but also useful for debugging
      _errorMessage.value = 'Error fetching condition: $e';
      _condition.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Reset controller state
  void clear() {
    _condition.value = null;
    _errorMessage.value = null;
    _isLoading.value = false;
  }
}
