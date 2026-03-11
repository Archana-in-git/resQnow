import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/notification_controller.dart';

class NotificationListener extends StatefulWidget {
  final Widget child;

  const NotificationListener({super.key, required this.child});

  @override
  State<NotificationListener> createState() => _NotificationListenerState();
}

class _NotificationListenerState extends State<NotificationListener> {
  late NotificationController _notificationController;
  final Set<String> _shownNotifications = {};
  late FirebaseAuth _auth;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _notificationController = context.read<NotificationController>();

    // Listen for auth state changes
    _auth.authStateChanges().listen((user) {
      if (user != null && !_initialized) {
        // User logged in, initialize notifications
        _initialized = true;
        _notificationController.initializeNotifications();
        _notificationController.addListener(_checkForNewNotifications);
      } else if (user == null) {
        // User logged out
        _initialized = false;
      }
    });

    // If user is already logged in (app restart)
    if (_auth.currentUser != null && !_initialized) {
      _initialized = true;
      _notificationController.initializeNotifications();
      _notificationController.addListener(_checkForNewNotifications);
    }
  }

  void _checkForNewNotifications() {
    final latest = _notificationController.getLatestUnread();
    if (latest != null && !_shownNotifications.contains(latest['id'])) {
      _shownNotifications.add(latest['id']);
      _showNotificationSnackBar(latest);
    }
  }

  void _showNotificationSnackBar(Map<String, dynamic> notification) {
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger == null) {
      return;
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['title'] ?? 'New Notification',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              notification['message'] ?? '',
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        duration: const Duration(seconds: 6),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Mark Read',
          textColor: Colors.white,
          onPressed: () {
            _notificationController.markAsRead(notification['id']);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notificationController.removeListener(_checkForNewNotifications);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
