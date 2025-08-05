import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'features/presentation/navigation/app_router.dart';
import 'core/theme/theme_manager.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'package:resqnow/features/condition_categories/presentation/controllers/category_controller.dart';
import 'package:resqnow/features/condition_categories/data/services/category_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
