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

  /// Fetch a condition by ID
  Future<void> fetchCondition(String id) async {
    _isLoading.value = true;
    _errorMessage.value = null;

    try {
      _condition.value = await _conditionService.getConditionById(id);
    } catch (e) {
      _errorMessage.value = e.toString();
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
