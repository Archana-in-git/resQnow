import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../models/emergency_model.dart';

class EmergencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<EmergencyContact?> fetchUserEmergencyContact(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('contacts')
        .doc('primary')
        .get();
    if (doc.exists) {
      return EmergencyContact.fromMap(doc.data()!);
    }
    return null;
  }

  /// Log emergency button click to Firestore for real-time dashboard tracking
  /// This ensures the admin dashboard shows accurate emergency statistics
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

      // Get device location if available
      Map<String, dynamic> locationData = {};
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        locationData = {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
        };
      } catch (e) {
        // If location unavailable, continue without it
        print('Could not get location: $e');
      }

      // Add emergency log document to Firestore
      await _firestore.collection('emergency_logs').add({
        'userId': currentUser.uid,
        'userEmail': currentUser.email,
        'timestamp': DateTime.now().toIso8601String(),
        'emergencyNumber': emergencyNumber,
        'severity': severity,
        'status':
            'initiated', // can be: initiated, in_progress, completed, failed
        'location': locationData.isNotEmpty ? locationData : null,
        'platform': 'mobile_app', // helps distinguish from web admin actions
      });

      print('✅ Emergency click logged successfully to Firestore');
    } catch (e) {
      print('❌ Error logging emergency click to Firestore: $e');
      // Don't throw - we don't want logging failures to block the emergency call
    }
  }
}
