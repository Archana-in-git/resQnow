import 'package:go_router/go_router.dart';
import 'package:resqnow/features/emergency/presentation/pages/emergency_page.dart';
import 'package:resqnow/features/condition_categories/presentation/pages/category_list_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/categories',
    routes: [
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoryListPage(),
      ),
      GoRoute(
        path: '/emergency',
        builder: (context, state) => const EmergencyPage(),
      ),
      // Route for emergency -> categories flow
      GoRoute(
        path: '/emergency-to-categories',
        redirect: (context, state) => '/categories',
      ),
    ],
  );
}
