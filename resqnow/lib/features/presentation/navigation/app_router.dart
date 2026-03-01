import 'package:resqnow/features/hospitals/presentation/pages/hospital_detail_page.dart';
import 'package:resqnow/features/hospitals/presentation/pages/appointment_form_page.dart';
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

// 🚨 Emergency & Categories
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

// 🏥 Workshops
import 'package:resqnow/features/workshops/presentation/pages/workshops_coming_soon_page.dart';

// 🩸 Blood
import 'package:resqnow/features/blood_donor/presentation/pages/bank/blood_bank_list_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_registration_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_profile_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_list_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_details_page.dart';

// 💬 Chat
import 'package:resqnow/features/chat/presentation/pages/chat_screen.dart';

// 👤 Profile
import 'package:resqnow/features/profile/presentation/profile_page.dart';

// 🏥 Hospital Locator (Old)
import 'package:resqnow/features/hospital_locator/presentation/pages/hospital_page.dart';

// 🏥 Approved Hospitals (New Clean Architecture)
import 'package:resqnow/features/hospitals/presentation/pages/hospitals_page.dart';

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

        final bool isAuthRoute =
            location == '/welcome' ||
            location == '/login' ||
            location == '/signup' ||
            location == '/success';

        final bool isProtectedRoute =
            location == '/workshops' || location.startsWith('/workshops/');

        if (location == '/splash') return null;

        if (isProtectedRoute && !loggedIn) return '/welcome';

        if (!loggedIn && !isAuthRoute) return '/welcome';

        if (loggedIn && isAuthRoute) {
          if (authController.isLoading) return null;
          return '/home';
        }

        return null;
      },

      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Page not found')),
        body: Center(child: Text('Error: ${state.error}')),
      ),

      routes: [
        GoRoute(
          path: '/hospital-details/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return HospitalDetailPage(hospitalId: id);
          },
        ),
        GoRoute(
          path: '/appointment-form/:hospitalId/:doctorId',
          builder: (context, state) {
            final hospitalId = state.pathParameters['hospitalId']!;
            final doctorId = state.pathParameters['doctorId']!;
            return AppointmentFormPage(
              hospitalId: hospitalId,
              doctorId: doctorId,
            );
          },
        ),
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),

        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomePage(),
        ),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpPage(),
        ),

        GoRoute(path: '/home', builder: (context, state) => const HomePage()),

        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationPage(),
        ),

        GoRoute(
          path: '/ai-chat-coming-soon',
          builder: (context, state) => const AiChatComingSoonPage(),
        ),

        GoRoute(
          path: '/saved-topics',
          builder: (context, state) => const SavedTopicsPage(),
        ),

        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),

        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),

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
          path: '/donor/details/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final extra = state.extra as Map<String, dynamic>?;
            return DonorDetailsPage(donorId: id, extra: extra);
          },
        ),

        GoRoute(
          path: '/chat/:otherUserId',
          builder: (context, state) {
            final otherUserId = state.pathParameters['otherUserId']!;
            final extra = state.extra as Map<String, dynamic>;
            return ChatScreen(
              otherUserId: otherUserId,
              otherUserName: extra['otherUserName'] as String,
              otherUserBloodGroup: extra['otherUserBloodGroup'] as String,
              otherUserImageUrl: extra['otherUserImageUrl'] as String?,
              currentUserName: extra['currentUserName'] as String,
              currentUserBloodGroup: extra['currentUserBloodGroup'] as String,
              currentUserImageUrl: extra['currentUserImageUrl'] as String?,
            );
          },
        ),

        /// 🏥 Hospital Locator (Old)
        GoRoute(
          path: '/hospital-locator',
          builder: (context, state) => const HospitalPage(),
        ),

        /// 🏥 Approved Hospitals (New Clean Architecture)
        GoRoute(
          path: '/approved-hospitals',
          builder: (context, state) => const HospitalsPage(),
        ),

        GoRoute(
          path: '/blood-banks',
          builder: (context, state) => const BloodBankListPage(),
        ),

        GoRoute(
          path: '/emergency',
          builder: (context, state) => const EmergencyPage(),
        ),

        GoRoute(
          path: '/emergency-numbers',
          builder: (context, state) => const EmergencyNumbersPage(),
        ),

        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoryListPage(),
        ),

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

        GoRoute(path: '/cart', builder: (context, state) => const CartPage()),

        GoRoute(
          path: '/workshops',
          builder: (context, state) => const WorkshopsComingSoonPage(),
        ),
      ],
    );
  }
}
