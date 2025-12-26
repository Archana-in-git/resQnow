import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:resqnow/features/authentication/presentation/controllers/auth_controller.dart';

// 🧭 Authentication
import 'package:resqnow/features/authentication/presentation/pages/welcome_page.dart';
import 'package:resqnow/features/authentication/presentation/pages/login_page.dart';
import 'package:resqnow/features/authentication/presentation/pages/signup_page.dart';

// 🏠 Home
import 'package:resqnow/features/presentation/pages/home_page.dart';
import 'package:resqnow/features/presentation/pages/splash_screen.dart';
import 'package:resqnow/features/presentation/pages/notification_page.dart';

// 🤖 AI Chat
import 'package:resqnow/features/presentation/pages/ai_chat_coming_soon_page.dart';

// 💾 Saved Topics
import 'package:resqnow/features/saved_topics/presentation/pages/saved_topics_page.dart';

// ⚙️ Settings
import 'package:resqnow/features/settings/presentation/pages/settings_page.dart';

// �🚨 Emergency & Categories
import 'package:resqnow/features/emergency/presentation/pages/emergency_page.dart';
import 'package:resqnow/features/emergency_numbers/presentation/pages/emergency_numbers_page.dart';
import 'package:resqnow/features/condition_categories/presentation/pages/category_list_page.dart';
import 'package:resqnow/features/medical_conditions/presentation/pages/condition_detail_page.dart';
import 'package:resqnow/features/medical_conditions/presentation/pages/condition_faq_page.dart';

// 📘 Resources
import 'package:resqnow/features/first_aid_resources/presentation/pages/resource_list_page.dart';
import 'package:resqnow/features/first_aid_resources/presentation/pages/resource_detail_page.dart';
import 'package:resqnow/domain/entities/resource.dart';

// 🛒 Shopping Cart
import 'package:resqnow/features/shopping_cart/presentation/pages/cart_page.dart';

// 🩸 Blood
import 'package:resqnow/features/blood_donor/presentation/pages/bank/blood_bank_list_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_registration_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_profile_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_list_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_filter_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_details_page.dart';

class AppRouter {
  static late GoRouter _router;
  static GoRouter? _routerInstance;

  // Initialize router only once
  static void init(BuildContext context) {
    if (_routerInstance != null) return;

    print('🔨 AppRouter.init() called - Creating router instance');
    final authController = context.read<AuthController>();
    print('🔨 AuthController accessed');
    _routerInstance = _createRouter(context);
  }

  // Get the static router instance
  static GoRouter getRouter() {
    if (_routerInstance == null) {
      throw Exception(
        'AppRouter not initialized. Call AppRouter.init() first.',
      );
    }
    return _routerInstance!;
  }

  // Create router (private)
  static GoRouter _createRouter(BuildContext context) {
    print('🔨 AppRouter._createRouter() called');

    final authController = context.read<AuthController>();
    print('🔨 AuthController accessed');

    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: Listenable.merge([authController]),

      redirect: (context, state) {
        final location = state.matchedLocation;
        print('🔄 Router redirect: $location');

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

        // 🎬 ALLOW SPLASH TO SHOW FIRST
        // The splash screen will handle navigation after animation completes
        if (location == '/splash') {
          debugPrint(
            'Decision: stay on /splash (let animation complete first)',
          );
          return null;
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

        /// HOME
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),

        /// NOTIFICATIONS
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationPage(),
        ),

        /// AI CHAT
        GoRoute(
          path: '/ai-chat-coming-soon',
          builder: (context, state) => const AiChatComingSoonPage(),
        ),

        /// SAVED TOPICS
        GoRoute(
          path: '/saved-topics',
          builder: (context, state) => const SavedTopicsPage(),
        ),

        /// SETTINGS
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),

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
              routes: [
                GoRoute(
                  path: 'faqs',
                  builder: (context, state) {
                    final id = state.pathParameters['conditionId']!;
                    final condition = state.extra as dynamic;
                    return ConditionFAQPage(
                      conditionId: id,
                      condition: condition,
                    );
                  },
                ),
              ],
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

        /// 🛒 SHOPPING CART
        GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
      ],
    );
  }

  // Legacy method for backward compatibility
  static GoRouter createRouter(BuildContext context) {
    init(context);
    return getRouter();
  }
}
