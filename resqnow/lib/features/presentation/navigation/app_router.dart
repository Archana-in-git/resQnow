import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:resqnow/features/emergency/presentation/pages/emergency_page.dart';
import 'package:resqnow/features/home/presentation/pages/home_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/emergency',
        builder: (context, state) => const EmergencyPage(),
      ),
    ],
  );
}
