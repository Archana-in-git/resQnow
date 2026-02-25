import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/notification_controller.dart';

class NotificationListener extends StatefulWidget {
  final Widget child;

  const NotificationListener({
    Key? key,
    required this.child,
  }) : super(key: key);

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
    print('🎯 NotificationListener initState called');
    _auth = FirebaseAuth.instance;
    _notificationController = context.read<NotificationController>();

    // Listen for auth state changes
    _auth.authStateChanges().listen((user) {
      print('🔐 Auth state changed: user = ${user?.email}');
      if (user != null && !_initialized) {
        // User logged in, initialize notifications
        print('✅ User logged in, initializing notifications');
        _initialized = true;
        _notificationController.initializeNotifications();
        _notificationController.addListener(_checkForNewNotifications);
        print('✅ Notification listener added');
      } else if (user == null) {
        // User logged out
        print('❌ User logged out');
        _initialized = false;
      }
    });

    // If user is already logged in (app restart)
    if (_auth.currentUser != null && !_initialized) {
      print('✅ App restart: user already logged in as ${_auth.currentUser?.email}');
      _initialized = true;
      _notificationController.initializeNotifications();
      _notificationController.addListener(_checkForNewNotifications);
      print('✅ Notification listener added (app restart)');
    } else if (_auth.currentUser == null) {
      print('⏳ Waiting for user to log in...');
    }
  }

  void _checkForNewNotifications() {
    print('🔍 Checking for new notifications...');
    final latest = _notificationController.getLatestUnread();
    print('🔍 Latest unread: ${latest?['id']}');
    if (latest != null && !_shownNotifications.contains(latest['id'])) {
      print('📢 Showing notification: ${latest['title']}');
      _shownNotifications.add(latest['id']);
      _showNotificationSnackBar(latest);
    } else if (latest == null) {
      print('🔍 No unread notifications');
    }
  }

  void _showNotificationSnackBar(Map<String, dynamic> notification) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['title'] ?? 'New Notification',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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
