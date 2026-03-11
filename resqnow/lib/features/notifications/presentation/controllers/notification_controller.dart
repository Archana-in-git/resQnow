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
    // Listen to notifications stream
    _notificationService.listenToNotifications().listen(
      (notifications) {
        _notifications = notifications;
        _updateUnreadCount();
        notifyListeners();
      },
      onError: (error) {
        // Handle error silently
      },
    );

    // Listen to unread count
    _notificationService.getUnreadCount().listen(
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
      onError: (error) {
        // Handle error silently
      },
    );
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
    notifyListeners();
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
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
      return _notifications.firstWhere((n) => !n['isRead']);
    } catch (e) {
      return null;
    }
  }
}
