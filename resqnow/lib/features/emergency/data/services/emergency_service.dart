import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Log emergency button click to Firestore for real-time dashboard tracking
  /// Optimized for speed - logs minimal data for instant response
  /// This ensures the admin dashboard shows accurate emergency statistics in real-time
  Future<void> logEmergencyClick({
    required String emergencyNumber,
    String severity = 'high',
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No authenticated user for emergency logging');
        return;
      }

      // Add emergency log document to Firestore with minimal data for speed
      await _firestore.collection('emergency_logs').add({
        'userId': currentUser.uid,
        'userEmail': currentUser.email,
        'timestamp': FieldValue.serverTimestamp(),
        'emergencyNumber': emergencyNumber,
        'severity': severity,
        'status':
            'initiated', // can be: initiated, in_progress, completed, failed
        'platform': 'mobile_app', // helps distinguish from web admin actions
      });

      print('✅ Emergency click logged successfully to Firestore');
    } catch (e) {
      print('❌ Error logging emergency click to Firestore: $e');
      // Don't throw - we don't want logging failures to block the emergency call
    }
  }
}
