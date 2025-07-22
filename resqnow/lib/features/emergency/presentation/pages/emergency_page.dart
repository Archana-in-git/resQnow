import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/emergency_button.dart';

class EmergencyButtonPage extends StatelessWidget {
  const EmergencyButtonPage({super.key});

  final String emergencyNumber = "108";

  Future<void> _makeEmergencyCall() async {
    final status = await Permission.phone.request();

    if (status.isGranted) {
      final Uri phoneUri = Uri(scheme: 'tel', path: emergencyNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        debugPrint("Could not launch dialer");
      }
    } else {
      // Optional: Show an alert/snackbar
      debugPrint("Call permission denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Exit Button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),

            // Center SOS Button
            Center(
              child: GestureDetector(
                onTap: _makeEmergencyCall,
                child: const AnimatedSOSButton(),
              ),
            ),

            // Bottom Text
            const Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Please standby, we are currently\nrequesting for help.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
