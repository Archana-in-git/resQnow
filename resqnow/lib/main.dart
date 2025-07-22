import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/emergency/presentation/pages/emergency_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class ResQNowApp extends StatelessWidget {
  const ResQNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQNow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const EmergencyBuutonPage(),
    );
  }
}
