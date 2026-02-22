import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppNotificationService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  AppNotificationService({required this.firestore, required this.auth});

  /// Stream user's notifications (real-time)
  Stream<List<Map<String, dynamic>>> getUserNotificationsStream() {
    final user = auth.currentUser;
    if (user == null) return Stream.value([]);

    return firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
  }

  /// Get unread count (real-time)
  Stream<int> getUnreadCountStream() {
    final user = auth.currentUser;
    if (user == null) return Stream.value(0);

    return firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await firestore.collection('notifications').doc(notificationId).delete();
  }

  /// Check if call request is approved
  Future<bool> isCallRequestApproved(String callRequestId) async {
    final doc = await firestore
        .collection('call_requests')
        .doc(callRequestId)
        .get();
    if (!doc.exists) return false;
    return doc['status'] == 'approved';
  }
}
