import 'package:go_router/go_router.dart';
import 'package:resqnow/features/emergency/presentation/pages/emergency_page.dart';
import 'package:resqnow/features/condition_categories/presentation/pages/category_list_page.dart';
import 'package:resqnow/features/medical_conditions/presentation/pages/condition_detail_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/categories',
    routes: [
      GoRoute(
        path: '/emergency',
        name: 'emergency',
        builder: (context, state) => const EmergencyPage(),
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoryListPage(),
        routes: [
          // Nested route - this ensures categories is the parent
          GoRoute(
            path: 'condition/:conditionId',
            name: 'conditionDetail',
            builder: (context, state) {
              final conditionId = state.pathParameters['conditionId']!;
              return ConditionDetailPage(conditionId: conditionId);
            },
          ),
        ],
      ),

      // ✅ Optional: redirect legacy paths
      GoRoute(
        path: '/condition/:conditionId',
        redirect: (context, state) {
          final conditionId = state.pathParameters['conditionId']!;
          return '/categories/condition/$conditionId';
        },
      ),
      GoRoute(
        path: '/category/:id',
        redirect: (context, state) {
          final id = state.pathParameters['id']!;
          return '/categories/condition/$id';
        },
      ),
    ],
  );
}
