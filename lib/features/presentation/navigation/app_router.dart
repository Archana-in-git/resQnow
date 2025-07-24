import 'package:go_router/go_router.dart';
//import 'package:resqnow/features/emergency/presentation/pages/emergency_page.dart';
import 'package:resqnow/features/authentication/presentation/pages/success_page.dart';


class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/success',
    routes: [
      GoRoute(
        path: '/success',
        builder: (context, state) => const SuccessPage(),
      ),
    ],
  );
}
