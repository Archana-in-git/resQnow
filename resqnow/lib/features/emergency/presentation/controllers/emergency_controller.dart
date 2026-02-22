import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/services/emergency_service.dart';

class EmergencyController {
  static const String emergencyNumber = '+919074346945';
  static final EmergencyService _emergencyService = EmergencyService();

  static Future<void> handleEmergencyCall() async {
    try {
      // Check phone permission
      final status = await Permission.phone.status;

      if (!status.isGranted) {
        final result = await Permission.phone.request();
        if (!result.isGranted) {
          debugPrint('Phone call permission denied.');
          return;
        }
      }

      // ✅ LOG EMERGENCY CLICK TO FIRESTORE FOR DASHBOARD
      // This ensures the admin dashboard shows accurate emergency statistics
      await _emergencyService.logEmergencyClick(
        emergencyNumber: emergencyNumber,
        severity: 'high',
      );

      // Make the phone call
      await FlutterPhoneDirectCaller.callNumber(emergencyNumber);
      debugPrint('Emergency call initiated to $emergencyNumber');
    } catch (e) {
      debugPrint("Error during emergency call: $e");
    }
  }
}
