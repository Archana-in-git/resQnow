import 'package:flutter/material.dart';
import 'package:resqnow/features/authentication/presentation/pages/welcome_page.dart';
import 'package:resqnow/features/authentication/presentation/pages/login_page.dart';
import 'package:resqnow/features/authentication/presentation/pages/signup_page.dart';
import 'package:resqnow/features/authentication/presentation/pages/success_page.dart';



void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medics App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const WelcomePage(),
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignUpPage(),
        '/success': (_) => const SuccessPage(),
        '/home': (_) => const Placeholder(), // Replace with your actual home page
      },
    );
  }
}
