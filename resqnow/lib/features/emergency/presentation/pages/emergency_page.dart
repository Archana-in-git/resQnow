import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resqnow/features/emergency/presentation/widgets/emergency_button.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Blackish background
      body: SafeArea(
        child: Stack(
          children: [
            const Center(child: EmergencyButton()),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => context.go('/categories'), // ✅ FIXED
                child: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
            const Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'EMERGENCY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Please standby, we are currently\nrequesting for help.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 32,
              right: 32,
              child: ElevatedButton(
                onPressed: () => context.go('/categories'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withAlpha(40),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.white30),
                  ),
                ),
                child: const Text(
                  'Get First Aid Help',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
