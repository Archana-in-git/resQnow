import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resqnow/features/emergency/presentation/pages/emergency_page.dart';
import 'package:resqnow/features/home/presentation/pages/home_page.dart';
import 'package:resqnow/features/condition_categories/presentation/pages/category_list_page.dart';
import 'package:resqnow/features/medical_conditions/presentation/pages/condition_detail_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/emergency',
        builder: (context, state) => const EmergencyPage(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoryListPage(),
      ),
      GoRoute(
        path: '/condition/:id',
        builder: (context, state) {
          final conditionId = state.params['id']!;
          return ConditionDetailPage(conditionId: conditionId);
        },
      ),
    ],
  );
}
