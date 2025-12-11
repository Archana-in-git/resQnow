import 'package:go_router/go_router.dart';

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

// 🩸 Blood Banks
import 'package:resqnow/features/blood_donor/presentation/pages/bank/blood_bank_list_page.dart';

// 🩸 BLOOD DONOR MODULE (NEW)
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_registration_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_profile_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_list_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_filter_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/donor/donor_details_page.dart';
import 'package:resqnow/features/blood_donor/presentation/pages/blood_landing_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    // ⭐ INITIAL SCREEN: Home Page
    initialLocation: '/home',

    routes: [
      GoRoute(
        path: '/blood',
        name: 'bloodLanding',
        builder: (context, state) => const BloodLandingPage(),
      ),

      /// ----------------------------------------
      /// ⭐ BLOOD DONOR MODULE ROUTES (NEW)
      /// ----------------------------------------

      // 1️⃣ Donor List Page (initial)
      GoRoute(
        path: '/donors',
        name: 'donorList',
        builder: (context, state) => const DonorListPage(),
      ),

      // 2️⃣ Donor Registration Page
      GoRoute(
        path: '/donor/register',
        name: 'donorRegister',
        builder: (context, state) => const DonorRegistrationPage(),
      ),

      // 3️⃣ Donor Profile Page
      GoRoute(
        path: '/donor/profile',
        name: 'donorProfile',
        builder: (context, state) => const DonorProfilePage(),
      ),

      // 4️⃣ Donor Filter Page
      GoRoute(
        path: '/donor/filter',
        name: 'donorFilter',
        builder: (context, state) => const DonorFilterPage(),
      ),

      // 5️⃣ Donor Details Page
      GoRoute(
        path: '/donor/details/:id',
        name: 'donorDetails',
        builder: (context, state) {
          final donorId = state.pathParameters['id']!;
          return DonorDetailsPage(donorId: donorId);
        },
      ),

      /// ----------------------------------------
      /// 🩸 BLOOD BANK PAGE (existing)
      /// ----------------------------------------
      GoRoute(
        path: '/blood-banks',
        name: 'bloodBanks',
        builder: (context, state) => const BloodBankListPage(),
      ),

      /// ----------------------------------------
      /// 🧭 Authentication Flow
      /// ----------------------------------------
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/success',
        name: 'success',
        builder: (context, state) => const SuccessPage(),
      ),

      /// ----------------------------------------
      /// 🏠 Home Page
      /// ----------------------------------------
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      /// ----------------------------------------
      /// 🚨 Emergency Page
      /// ----------------------------------------
      GoRoute(
        path: '/emergency',
        name: 'emergency',
        builder: (context, state) => const EmergencyPage(),
      ),

      /// ----------------------------------------
      /// ☎️ Emergency Numbers Page
      /// ----------------------------------------
      GoRoute(
        path: '/emergency-numbers',
        name: 'emergencyNumbers',
        builder: (context, state) => const EmergencyNumbersPage(),
      ),

      /// ----------------------------------------
      /// 🩺 Categories Page
      /// ----------------------------------------
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

      /// ----------------------------------------
      /// 📘 First-Aid Resources
      /// ----------------------------------------
      GoRoute(
        path: '/resources',
        name: 'resources',
        builder: (context, state) => const ResourceListPage(),
      ),

      GoRoute(
        path: '/resource-detail',
        name: 'resourceDetail',
        builder: (context, state) {
          final resource = state.extra as Resource;
          return ResourceDetailPage(resource: resource);
        },
      ),

      /// ----------------------------------------
      /// 🔁 Redirects (Old → New)
      /// ----------------------------------------
      GoRoute(
        path: '/condition/:conditionId',
        redirect: (context, state) {
          final id = state.pathParameters['conditionId']!;
          return '/categories/condition/$id';
        },
      ),

      GoRoute(
        path: '/category/:id',
        redirect: (context, state) {
          final id = state.pathParameters['id']!;
          return '/categories/condition/$id';
        },
      ),

      /// ----------------------------------------
      /// Splash
      /// ----------------------------------------
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
    ],
  );
}
