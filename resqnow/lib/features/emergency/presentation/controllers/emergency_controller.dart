import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyController {
  static const String emergencyNumber = 'tel:123';

  static Future<void> handleEmergencyCall() async {
    final Uri callUri = Uri.parse(emergencyNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      debugPrint("Could not launch emergency call.");
    }
  }
}
