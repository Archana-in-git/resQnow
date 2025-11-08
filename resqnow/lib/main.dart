import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Firebase config
import 'firebase_options.dart';

// App router
import 'features/presentation/navigation/app_router.dart';

// Theme
import 'core/theme/theme_manager.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';

// Category management
import 'package:resqnow/features/condition_categories/presentation/controllers/category_controller.dart';
import 'package:resqnow/features/condition_categories/data/services/category_service.dart';

// ✅ Resource management
import 'package:resqnow/features/first_aid_resources/presentation/controllers/resource_controller.dart';
import 'package:resqnow/domain/usecases/get_resources.dart';
import 'package:resqnow/data/repositories/resource_repository_impl.dart';
import 'package:resqnow/data/datasources/remote/resource_remote_datasource.dart';

// ✅ Location management
import 'package:resqnow/features/presentation/controllers/home_controller.dart';
import 'package:resqnow/features/presentation/controllers/location_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("🔥 Firebase initialization error: $e");
  }

  runApp(const ResQNowApp());
}

class ResQNowApp extends StatelessWidget {
  const ResQNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),

        /// ✅ Categories
        ChangeNotifierProvider(
          create: (_) =>
              CategoryController(CategoryService())..loadCategories(),
        ),

        /// ✅ Resources
        ChangeNotifierProvider(
          create: (_) => ResourceController(
            getResourcesUseCase: GetResources(
              ResourceRepositoryImpl(
                remoteDataSource: ResourceRemoteDataSourceImpl(
                  firestore: FirebaseFirestore.instance,
                ),
              ),
            ),
          ),
        ),

        /// ✅ Location
        ChangeNotifierProvider(
          create: (_) => LocationController()..fetchLocation(),
        ),

        /// Add HomeController so Consumer<HomeController> in HomePage works
        ChangeNotifierProvider(
          create: (_) => HomeController()..initializeHomeData(),
        ),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, _) {
          return MaterialApp.router(
            title: 'ResQNow',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeManager.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
