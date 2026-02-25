import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationListenerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Listen to real-time notifications for current user
  Stream<List<Map<String, dynamic>>> listenToNotifications() {
    final user = _auth.currentUser;
    print('🔔 NotificationListenerService.listenToNotifications() called');
    print('   Current user: ${user?.uid}');
    
    if (user == null) {
      print('   No user logged in, returning empty stream');
      return Stream.value([]);
    }

    print('   Setting up listener for userId: ${user.uid}');
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('   📥 Received ${snapshot.docs.length} notifications');
          for (var doc in snapshot.docs) {
            print('   - ${doc.data()}');
          }
          return snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
        });
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      print('✅ Marking notification as read: $notificationId');
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      print('🗑️  Deleting notification: $notificationId');
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('❌ Error deleting notification: $e');
    }
  }

  /// Get unread notifications count
  Stream<int> getUnreadCount() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          print('📊 Unread count: ${snapshot.docs.length}');
          return snapshot.docs.length;
        });
  }
}