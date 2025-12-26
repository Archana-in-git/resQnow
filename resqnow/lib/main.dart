import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'features/presentation/navigation/app_router.dart';

// THEME
import 'core/theme/theme_manager.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';

// CATEGORY
import 'features/condition_categories/data/services/category_service.dart';
import 'features/condition_categories/presentation/controllers/category_controller.dart';

// RESOURCES
import 'data/datasources/remote/resource_remote_datasource.dart';
import 'data/repositories/resource_repository_impl.dart';
import 'domain/usecases/get_resources.dart';
import 'features/first_aid_resources/presentation/controllers/resource_controller.dart';

// LOCATION + AUTH
import 'features/presentation/controllers/location_controller.dart';
import 'features/authentication/presentation/controllers/auth_controller.dart';

// ⭐ BLOOD BANK MODULE
import 'features/blood_donor/data/services/blood_bank_service.dart';
import 'data/repositories/blood_bank_repository_impl.dart';
import 'domain/usecases/get_blood_banks_nearby.dart';

// ⭐ BLOOD DONOR MODULE
import 'features/blood_donor/data/services/blood_donor_service.dart';
import 'data/repositories/blood_donor_repository_impl.dart';

// 🛒 SHOPPING CART MODULE
import 'features/shopping_cart/presentation/controllers/cart_controller.dart';

import 'domain/usecases/register_donor.dart';
import 'domain/usecases/update_donor.dart';
import 'domain/usecases/delete_donor.dart';
import 'domain/usecases/get_my_donor_profile.dart';
import 'domain/usecases/get_donors.dart' as get_donors;
import 'domain/usecases/get_all_donors.dart';
import 'domain/usecases/filter_donors.dart';
import 'domain/usecases/is_user_donor.dart';
import 'domain/usecases/get_donor_by_id.dart';

import 'features/blood_donor/presentation/controllers/donor_registration_controller.dart';
import 'features/blood_donor/presentation/controllers/donor_profile_controller.dart';
import 'features/blood_donor/presentation/controllers/donor_list_controller.dart';
import 'features/blood_donor/presentation/controllers/donor_filter_controller.dart';
import 'features/blood_donor/presentation/controllers/donor_details_controller.dart';

import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  print('✅ STEP 1: main() started');

  WidgetsFlutterBinding.ensureInitialized();
  print('✅ STEP 2: WidgetsFlutterBinding.ensureInitialized()');

  // Initialize ThemeManager to load saved theme preference
  final themeManager = ThemeManager();
  await themeManager.initTheme();
  print('✅ STEP 2.5: ThemeManager initialized with saved preference');

  try {
    // Try to initialize Firebase - it may already be initialized
    if (Firebase.apps.isEmpty) {
      print('✅ STEP 3a: Firebase apps list is empty, initializing...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ STEP 3: Firebase initialized');
    } else {
      print('✅ STEP 3: Firebase already initialized, skipping init');
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('✅ STEP 3: Firebase already initialized (caught exception)');
    } else {
      print('❌ STEP 3: Firebase init error: $e');
      rethrow;
    }
  }

  final firestore = FirebaseFirestore.instance;
  print('✅ STEP 4: Firestore instance created');

  final categoryService = CategoryService();
  print('✅ STEP 5: CategoryService created');

  final resourceRemoteDataSource = ResourceRemoteDataSourceImpl(
    firestore: firestore,
  );
  print('✅ STEP 6: ResourceRemoteDataSource created');

  final resourceRepository = ResourceRepositoryImpl(
    remoteDataSource: resourceRemoteDataSource,
  );
  print('✅ STEP 7: ResourceRepository created');

  final getResourcesUseCase = GetResources(resourceRepository);
  print('✅ STEP 8: GetResourcesUseCase created');

  print('✅ STEP 9: Starting runApp with MultiProvider');
  runApp(
    MultiProvider(
      providers: [
        // THEME
        ChangeNotifierProvider.value(value: themeManager),

        // LOCATION
        ChangeNotifierProvider(create: (_) => LocationController()),

        // AUTH (MUST be above router)
        ChangeNotifierProvider(create: (_) => AuthController()),

        // CATEGORY
        ChangeNotifierProvider(
          create: (_) => CategoryController(categoryService),
        ),

        // RESOURCES
        ChangeNotifierProvider(
          create: (_) =>
              ResourceController(getResourcesUseCase: getResourcesUseCase),
        ),

        // ⭐ BLOOD BANK MODULE
        Provider(
          create: (_) => BloodBankService(
            apiKey: "AIzaSyDZxL1FwXcsvoFFTJ3aHJNNOq3r4Bk_pFs",
          ),
        ),
        Provider(
          create: (context) => BloodBankRepositoryImpl(
            service: context.read<BloodBankService>(),
          ),
        ),
        Provider(
          create: (context) =>
              GetBloodBanksNearby(context.read<BloodBankRepositoryImpl>()),
        ),

        // ⭐ BLOOD DONOR MODULE
        Provider(
          create: (_) => BloodDonorService(
            firestore: firestore,
            auth: FirebaseAuth.instance,
          ),
        ),
        Provider(
          create: (context) => BloodDonorRepositoryImpl(
            service: context.read<BloodDonorService>(),
          ),
        ),

        Provider(
          create: (context) =>
              RegisterDonor(context.read<BloodDonorRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              UpdateDonor(context.read<BloodDonorRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              GetMyDonorProfile(context.read<BloodDonorRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              DeleteDonor(context.read<BloodDonorRepositoryImpl>()),
        ),

        Provider(
          create: (context) => get_donors.GetDonorsByDistrict(
            context.read<BloodDonorRepositoryImpl>(),
          ),
        ),
        Provider(
          create: (context) => get_donors.GetDonorsByTown(
            context.read<BloodDonorRepositoryImpl>(),
          ),
        ),
        Provider<GetAllDonors>(
          lazy: false,
          create: (context) {
            final repository = context.read<BloodDonorRepositoryImpl>();
            return GetAllDonors(repository);
          },
        ),
        Provider(
          create: (context) =>
              FilterDonors(context.read<BloodDonorRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              IsUserDonor(context.read<BloodDonorRepositoryImpl>()),
        ),
        Provider(
          create: (context) =>
              GetDonorById(context.read<BloodDonorRepositoryImpl>()),
        ),

        ChangeNotifierProvider(
          create: (context) => DonorRegistrationController(
            registerDonorUseCase: context.read<RegisterDonor>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DonorProfileController(
            getMyDonorProfileUseCase: context.read<GetMyDonorProfile>(),
            updateDonorUseCase: context.read<UpdateDonor>(),
            deleteDonorUseCase: context.read<DeleteDonor>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DonorListController(
            getDonorsByDistrictUseCase: context
                .read<get_donors.GetDonorsByDistrict>(),
            getDonorsByTownUseCase: context.read<get_donors.GetDonorsByTown>(),
            getAllDonorsUseCase: context.read<GetAllDonors>(),
            locationController: context.read<LocationController>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DonorFilterController(
            filterDonorsUseCase: context.read<FilterDonors>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DonorDetailsController(
            getDonorByIdUseCase: context.read<GetDonorById>(),
          ),
        ),

        // 🛒 SHOPPING CART
        ChangeNotifierProvider(create: (_) => CartController()),
      ],
      child: const ResQNowApp(),
    ),
  );
  print('✅ STEP 10: runApp completed successfully');
}

class ResQNowApp extends StatelessWidget {
  const ResQNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🔨 ResQNowApp.build() called');

    // Initialize router only once on first build
    AppRouter.init(context);

    // Watch theme changes for smooth transitions
    final themeManager = context.watch<ThemeManager>();
    print('🔨 ThemeManager accessed - Theme: ${themeManager.themeMode}');

    return MaterialApp.router(
      title: 'ResQNow',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeManager.themeMode,

      // ✅ USE STATIC ROUTER INSTANCE (prevents recreation on theme change)
      routerConfig: AppRouter.getRouter(),
    );
  }
}
