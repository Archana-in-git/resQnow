import 'package:flutter/material.dart';
import 'package:resqnow/domain/entities/category.dart';

/// Minimal HomeController used by HomePage.
/// Replace simulated load with real service calls later.
class HomeController extends ChangeNotifier {
  List<Category> categories = [];
  bool isLoading = false;
  String? error;

  HomeController();

  Future<void> initializeHomeData() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Replace this with real fetch logic (CategoryService) when ready.
      await Future.delayed(const Duration(milliseconds: 300));
      categories = []; // empty for now; populate from service/API
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
