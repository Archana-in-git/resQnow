import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:resqnow/features/authentication/presentation/controllers/auth_controller.dart';

// 🧭 Authentication
import 'package:resqnow/features/authentication/presentation/pages/welcome_page.dart';
import 'package:resqnow/features/authentication/presentation/pages/login_page.dart';
import 'package:resqnow/features/authentication/presentation/pages/signup_page.dart';
import 'package:resqnow/features/authentication/presentation/pages/success_page.dart';

// 🏠 Home
import 'package:resqnow/features/presentation/pages/home_page.dart';
import 'package:resqnow/features/presentation/pages/splash_screen.dart';

// 🚨 Emergency & Categories
import 'package:resqnow/features/emergency/presentation/pages/emergency_page.dart';
import 'package:resqnow/features/emergency_numbers/presentation/pages/emergency_numbers_page.dart';
import 'package:resqnow/features/condition_categories/presentation/pages/category_list_page.dart';
import 'package:resqnow/features/medical_conditions/presentation/pages/condition_detail_page.dart';

// 📘 Resources
import 'package:resqnow/features/first_aid_resources/presentation/pages/resource_list_page.dart';
import 'package:resqnow/features/first_aid_resources/presentation/pages/resource_detail_page.dart';
import 'package:resqnow/domain/entities/resource.dart';

// 🩸 Blood
import 'package:resqnow/features/blood_donor/presentation/pages/bank/blood_bank_list_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_registration_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_profile_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_list_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_filter_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_details_page.dart';

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    final authController = context.read<AuthController>();

    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: Listenable.merge([authController]),

      redirect: (context, state) {
        final location = state.matchedLocation;

        final user = FirebaseAuth.instance.currentUser;
        final loggedIn = user != null;

        // 🔍 DEBUG LOGS (DO NOT REMOVE YET)
        debugPrint('--- ROUTER REDIRECT ---');
        debugPrint('location      : $location');
        debugPrint('currentUser   : ${user?.uid}');
        debugPrint('loggedIn      : $loggedIn');

        final bool isAuthRoute =
            location == '/welcome' ||
            location == '/login' ||
            location == '/signup' ||
            location == '/success';

        debugPrint('isAuthRoute   : $isAuthRoute');

        if (location == '/splash') {
          return '/welcome';
        }

        if (!loggedIn && !isAuthRoute) {
          debugPrint('Decision: redirect to /welcome');
          return '/welcome';
        }

        if (loggedIn && isAuthRoute) {
          debugPrint('Decision: redirect to /home');
          return '/home';
        }

        debugPrint('Decision: no redirect');
        return null;
      },

      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Page not found')),
        body: Center(child: Text('Error: ${state.error}')),
      ),

      routes: [
        /// SPLASH
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),

        /// AUTH
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomePage(),
        ),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: '/success',
          builder: (context, state) => const SuccessPage(),
        ),

        /// HOME
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),

        /// DONORS
        GoRoute(
          path: '/donors',
          builder: (context, state) => const DonorListPage(),
        ),
        GoRoute(
          path: '/donor/register',
          builder: (context, state) => const DonorRegistrationPage(),
        ),
        GoRoute(
          path: '/donor/profile',
          builder: (context, state) => const DonorProfilePage(),
        ),
        GoRoute(
          path: '/donor/filter',
          builder: (context, state) => const DonorFilterPage(),
        ),
        GoRoute(
          path: '/donor/details/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return DonorDetailsPage(donorId: id);
          },
        ),

        /// BLOOD BANKS
        GoRoute(
          path: '/blood-banks',
          builder: (context, state) => const BloodBankListPage(),
        ),

        /// EMERGENCY
        GoRoute(
          path: '/emergency',
          builder: (context, state) => const EmergencyPage(),
        ),
        GoRoute(
          path: '/emergency-numbers',
          builder: (context, state) => const EmergencyNumbersPage(),
        ),

        /// CATEGORIES
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoryListPage(),
          routes: [
            GoRoute(
              path: 'condition/:conditionId',
              builder: (context, state) {
                final id = state.pathParameters['conditionId']!;
                return ConditionDetailPage(conditionId: id);
              },
            ),
          ],
        ),

        /// RESOURCES
        GoRoute(
          path: '/resources',
          builder: (context, state) => const ResourceListPage(),
        ),
        GoRoute(
          path: '/resource-detail',
          builder: (context, state) {
            final resource = state.extra as Resource;
            return ResourceDetailPage(resource: resource);
          },
        ),
      ],
    );
  }
}
