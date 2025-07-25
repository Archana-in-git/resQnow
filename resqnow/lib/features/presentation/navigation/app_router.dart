import 'package:go_router/go_router.dart';
import 'package:resqnow/features/emergency/presentation/pages/emergency_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/emergency',
    routes: [
      GoRoute(
        path: '/emergency',
        builder: (context, state) => const EmergencyPage(),
      ),
    ],
  );
}
