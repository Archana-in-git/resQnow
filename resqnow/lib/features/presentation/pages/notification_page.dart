import 'package:flutter/material.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/core/constants/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Updates', 'Features', 'Alerts'];

  // Sample notifications data structure (for future admin integration)
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Welcome to ResQNow!',
      description:
          'You have successfully registered. Start exploring first aid resources and connect with blood donors.',
      type: 'Updates',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
      icon: Icons.health_and_safety,
      color: AppColors.primary,
    ),
    NotificationItem(
      id: '2',
      title: 'New First Aid Category Added',
      description:
          'Explore our new "Sports Injuries" category with expert guidance and resources.',
      type: 'Features',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      icon: Icons.sports_soccer,
      color: Colors.orange,
    ),
    NotificationItem(
      id: '3',
      title: 'Blood Bank Near You',
      description:
          'A new blood bank has been added in your area. Check available blood types and donation camps.',
      type: 'Alerts',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
      icon: Icons.local_hospital,
      color: Colors.red,
    ),
    NotificationItem(
      id: '4',
      title: 'App Update Available',
      description:
          'Version 2.1.0 is now available with performance improvements and bug fixes.',
      type: 'Updates',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      icon: Icons.system_update,
      color: Colors.blue,
    ),
    NotificationItem(
      id: '5',
      title: 'AI Chat Assistant Launched',
      description:
          'Get instant answers to your health questions with our new AI-powered chat assistant.',
      type: 'Features',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      icon: Icons.smart_toy,
      color: Colors.purple,
    ),
    NotificationItem(
      id: '6',
      title: 'Emergency Response Team Update',
      description:
          'Our emergency response network has expanded to cover more areas. You are now in the coverage zone.',
      type: 'Alerts',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      icon: Icons.emergency,
      color: Colors.deepOrange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _selectedFilter == 'All'
        ? _notifications
        : _notifications.where((n) => n.type == _selectedFilter).toList();

    final unreadCount = _notifications.where((n) => !n.isRead).length;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey.shade800 : AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Notifications",
          style: AppTextStyles.appTitle.copyWith(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Filter Chips
            SizedBox(
              height: 45,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filterOptions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final filter = _filterOptions[index];
                  final isSelected = _selectedFilter == filter;
                  final isDarkMode =
                      Theme.of(context).brightness == Brightness.dark;
                  return FilterChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDarkMode
                                  ? Colors.white70
                                  : AppColors.textPrimary),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade100,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : (isDarkMode
                                ? Colors.grey.shade600
                                : Colors.grey.shade300),
                      width: 1,
                    ),
                    onSelected: (value) {
                      if (value) {
                        setState(() => _selectedFilter = filter);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Notifications List
            Expanded(
              child: filteredNotifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: filteredNotifications.length,
                      itemBuilder: (_, index) {
                        final notification = filteredNotifications[index];
                        return _NotificationCard(
                          notification: notification,
                          onTap: () => _handleNotificationTap(notification),
                          onDismiss: () =>
                              _dismissNotification(notification.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: isDarkMode ? AppColors.primary : AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications Yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up! We\'ll notify you when\nsomething important happens.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDarkMode
                  ? Colors.grey.shade400
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Mark as read
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(isRead: true);
      }
    });

    // Future: Navigate to relevant page based on notification type
    // Example: if (notification.type == 'Features') context.push('/features');
  }

  void _dismissNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification dismissed'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Undo logic can be implemented here
          },
        ),
      ),
    );
  }
}

// Notification Card Widget
class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black26 : AppColors.cardShadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border(left: BorderSide(color: notification.color, width: 4)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Container
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: notification.color.withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: Icon(
                        notification.icon,
                        color: notification.color,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : AppColors.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(notification.timestamp),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDarkMode
                                    ? Colors.grey.shade500
                                    : AppColors.textSecondary.withValues(
                                        alpha: 0.7,
                                      ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: notification.color.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                notification.type,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: notification.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

// Notification Data Model
class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String type; // 'Updates', 'Features', 'Alerts'
  final DateTime timestamp;
  final bool isRead;
  final IconData icon;
  final Color color;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    required this.isRead,
    required this.icon,
    required this.color,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    IconData? icon,
    Color? color,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
