import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize FCM and save token to Firestore
  Future<void> initializeFCM() async {
    try {
      // Request user permission for notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        print('User denied notification permission');
        return;
      }

      // Get and save FCM token
      String? token = await _messaging.getToken();
      if (token != null) {
        await _saveFCMToken(token);
      }
    
      // Listen for token refresh
      _messaging.onTokenRefresh.listen((token) => _saveFCMToken(token));

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message in the foreground: ${message.messageId}');
        // Handle foreground notification here
      });

      print('FCM initialized successfully with token: $token');
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  /// Save FCM token to user's Firestore document
  Future<void> _saveFCMToken(String? token) async {
    if (token == null) return;
    try {
      final user = _auth.currentUser;
      if (user != null) {
        try {
          await _firestore.collection('users').doc(user.uid).update({
            'fcmToken': token,
            'lastTokenUpdate': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          // If user doc doesn't exist yet, create it
          if (e is FirebaseException && e.code == 'not-found') {
            await _firestore.collection('users').doc(user.uid).set({
              'fcmToken': token,
              'lastTokenUpdate': DateTime.now().toIso8601String(),
            }, SetOptions(merge: true));
          } else {
            rethrow;
          }
        }
        print('FCM token saved to Firestore');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }
}