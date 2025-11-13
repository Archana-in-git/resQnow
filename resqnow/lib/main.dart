import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'features/presentation/navigation/app_router.dart';

import 'core/theme/theme_manager.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';

import 'features/condition_categories/data/services/category_service.dart';
import 'features/condition_categories/presentation/controllers/category_controller.dart';

import 'data/datasources/remote/resource_remote_datasource.dart';
import 'data/repositories/resource_repository_impl.dart';
import 'domain/usecases/get_resources.dart';
import 'features/first_aid_resources/presentation/controllers/resource_controller.dart';

import 'features/presentation/controllers/location_controller.dart';
import 'features/authentication/presentation/controllers/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;
  final categoryService = CategoryService();

  final resourceRemoteDataSource = ResourceRemoteDataSourceImpl(
    firestore: firestore,
  );
  final resourceRepository = ResourceRepositoryImpl(
    remoteDataSource: resourceRemoteDataSource,
  );
  final getResourcesUseCase = GetResources(resourceRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => LocationController()),
        ChangeNotifierProvider(
          create: (_) => CategoryController(categoryService),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ResourceController(getResourcesUseCase: getResourcesUseCase),
        ),
        ChangeNotifierProvider(create: (_) => AuthController()),
      ],
      child: const ResQNowApp(),
    ),
  );
}

class ResQNowApp extends StatelessWidget {
  const ResQNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return MaterialApp.router(
      title: 'ResQNow',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeManager.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
