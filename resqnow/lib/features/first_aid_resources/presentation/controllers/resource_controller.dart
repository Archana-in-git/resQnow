import 'package:flutter/material.dart';
import 'package:resqnow/domain/entities/resource.dart';
import 'package:resqnow/domain/usecases/get_resources.dart';

class ResourceController extends ChangeNotifier {
  final GetResources getResourcesUseCase;

  ResourceController({required this.getResourcesUseCase});

  List<Resource> _resources = [];
  List<Resource> get resources => _resources;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchResources() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _resources = await getResourcesUseCase();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
