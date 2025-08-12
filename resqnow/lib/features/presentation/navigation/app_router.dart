import 'package:go_router/go_router.dart';
import 'package:resqnow/features/emergency/presentation/pages/emergency_page.dart';
import 'package:resqnow/features/emergency_numbers/presentation/pages/emergency_numbers_page.dart';
import 'package:resqnow/features/condition_categories/presentation/pages/category_list_page.dart';
import 'package:resqnow/features/medical_conditions/presentation/pages/condition_detail_page.dart';
import 'package:resqnow/features/authentication/presentation/pages/login_page.dart';
import 'package:resqnow/features/authentication/presentation/pages/signup_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),

      // Emergency routes
      GoRoute(
        path: '/emergency',
        name: 'emergency',
        builder: (context, state) => const EmergencyPage(),
      ),
      GoRoute(
        path: '/emergency-numbers',
        name: 'emergencyNumbers',
        builder: (context, state) => const EmergencyNumbersPage(),
      ),

      // Category and condition routes
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoryListPage(),
        routes: [
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

      // Redirects for condition and category paths to nested routes
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
