import 'package:flutter/foundation.dart';
import 'package:resqnow/core/services/notification_service.dart';

class NotificationController with ChangeNotifier {
  final NotificationListenerService _notificationService =
      NotificationListenerService();

  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  /// Initialize notification listener
  void initializeNotifications() {
    print('🚀 NotificationController.initializeNotifications() started');
    
    // Listen to notifications stream
    _notificationService.listenToNotifications().listen((notifications) {
      print('📦 Notifications stream updated: ${notifications.length} notifications');
      _notifications = notifications;
      _updateUnreadCount();
      notifyListeners();
    }, onError: (error) {
      print('❌ Error in notifications stream: $error');
    });

    // Listen to unread count
    _notificationService.getUnreadCount().listen((count) {
      print('🔔 Unread count updated: $count');
      _unreadCount = count;
      notifyListeners();
    }, onError: (error) {
      print('❌ Error in unread count stream: $error');
    });
    
    print('✅ Notification listener initialized');
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    print('Marking notification $notificationId as read');
    await _notificationService.markAsRead(notificationId);
    notifyListeners();
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    print('Deleting notification $notificationId');
    await _notificationService.deleteNotification(notificationId);
    notifyListeners();
  }

  /// Calculate unread count manually
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n['isRead']).length;
  }

  /// Get latest unread notification
  Map<String, dynamic>? getLatestUnread() {
    try {
      final latest = _notifications.firstWhere((n) => !n['isRead']);
      print('📬 Latest unread notification: ${latest['title']}');
      return latest;
    } catch (e) {
      print('No unread notifications found');
      return null;
    }
  }
}
