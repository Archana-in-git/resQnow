import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencyController {
  static const String emergencyNumber = '+917907123800';

  static Future<void> handleEmergencyCall() async {
    try {
      final status = await Permission.phone.status;

      if (!status.isGranted) {
        final result = await Permission.phone.request();
        if (!result.isGranted) {
          debugPrint('Phone call permission denied.');
          return;
        }
      }

      await FlutterPhoneDirectCaller.callNumber(emergencyNumber);
      debugPrint('Emergency call initiated to $emergencyNumber');
    } catch (e) {
      debugPrint("Error making emergency call: $e");
    }
  }
}
