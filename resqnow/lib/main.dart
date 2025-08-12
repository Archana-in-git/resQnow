import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
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
        ChangeNotifierProvider(
          create: (_) =>
              CategoryController(CategoryService())..loadCategories(),
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
