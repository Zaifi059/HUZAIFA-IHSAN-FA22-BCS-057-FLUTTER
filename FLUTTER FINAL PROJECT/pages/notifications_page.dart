import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/notifications/presentation/providers/notification_providers.dart';
import '../core/config/supabase_config.dart';
import '../features/auth/data/providers/auth_provider.dart';
import '../core/theme/app_theme.dart';
import '../features/notifications/data/models/supabase_notification_model.dart';

/// Page to display all notifications
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications =
        ref.watch(supabaseNotificationsStreamProvider).maybeWhen(
              data: (items) => items,
              orElse: () => const <SupabaseNotificationModel>[],
            );
    final role = ref.watch(roleProvider);
    // Guard: only show "starting soon" when within the next ~30 minutes
    bool _isValidStartingSoon(SupabaseNotificationModel n) {
      if (n.type != 'game_reminder') return true;
      final when = n.scheduledFor;
      if (when == null) return false;
      final now = DateTime.now();
      final diff = when.difference(now);
      // only show if scheduled in the next 0..31 minutes
      return diff.inMinutes >= 0 && diff.inMinutes <= 31;
    }

    final filtered = notifications.where((n) {
      if (!_isValidStartingSoon(n)) return false;
      final t = n.type;
      final r = role?.value;
      if (r == 'referee') {
        if (t == 'game_accepted' || t == 'payout_requested') return false;
        return true; // allow payout_approved/completed and others
      }
      if (r == 'scheduler') {
        if (t == 'payout_approved' || t == 'payout_completed') return false;
        return true; // allow game_accepted and others
      }
      return true;
    }).toList();
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: AppTheme.skyBlue,
        foregroundColor: Colors.white,
        actions: [
          // Trigger test notification (DB-backed) for realtime verification
          if (notifications.isNotEmpty) ...[
            PopupMenuButton<String>(
              onSelected: (value) {
                final actions = ref.read(notificationActionsProvider);
                final userId = SupabaseConfig.client.auth.currentUser?.id;
                switch (value) {
                  case 'mark_all_read':
                    if (userId != null) {
                      actions.markAllAsRead(userId);
                    }
                    break;
                  case 'clear_all':
                    // Optional: implement bulk delete here if desired
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.mark_email_read),
                      SizedBox(width: 8),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all),
                      SizedBox(width: 8),
                      Text('Clear all'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: filtered.isEmpty
          ? _buildEmptyState(context)
          : _buildNotificationsList(context, ref, filtered),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    // No mock list anymore; show simple empty state while waiting for realtime
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.notifications_none, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('No notifications yet'),
        ],
      ),
    );
  }

  // Deprecated: kept for reference only; no longer used
  /* Widget _buildMockNotifications(BuildContext context) {
    final mockNotifications = [
      {
        'title': 'Game Assignment',
        'body':
            'You have been assigned to referee "Basketball Championship" on Dec 15, 2024 at 6:00 PM',
        'time': '2 minutes ago',
        'icon': Icons.sports_basketball,
        'color': Colors.orange,
        'isRead': false,
      },
      {
        'title': 'Payment Processed',
        'body':
            'Your payment of \$75.00 for game "Friday Night Basketball" has been processed',
        'time': '1 hour ago',
        'icon': Icons.payment,
        'color': Colors.green,
        'isRead': true,
      },
      {
        'title': 'Check-in Reminder',
        'body':
            'Don\'t forget to check in for your game starting in 30 minutes at Central High School',
        'time': '3 hours ago',
        'icon': Icons.location_on,
        'color': Colors.blue,
        'isRead': false,
      },
      {
        'title': 'Game Update',
        'body':
            'The venue for "Evening Basketball League" has been changed to West Side Community Center',
        'time': '1 day ago',
        'icon': Icons.update,
        'color': Colors.purple,
        'isRead': true,
      },
      {
        'title': 'New Game Available',
        'body':
            'A new game "Youth Basketball Tournament" is available for assignment. Fee: \$50.00',
        'time': '2 days ago',
        'icon': Icons.new_releases,
        'color': Colors.cyan,
        'isRead': false,
      },
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mock Notifications (Demo Data)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: mockNotifications.length,
            itemBuilder: (context, index) {
              final notification = mockNotifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        (notification['color'] as Color).withOpacity(0.1),
                    child: Icon(
                      notification['icon'] as IconData,
                      color: notification['color'] as Color,
                    ),
                  ),
                  title: Text(
                    notification['title'] as String,
                    style: TextStyle(
                      fontWeight: (notification['isRead'] as bool)
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notification['body'] as String),
                      const SizedBox(height: 4),
                      Text(
                        notification['time'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  trailing: !(notification['isRead'] as bool)
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                  isThreeLine: true,
                  onTap: () {
                    // Mark as read action would go here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opened: ${notification['title']}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  } */

  Widget _buildNotificationsList(
    BuildContext context,
    WidgetRef ref,
    List<SupabaseNotificationModel> notifications,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final actions = ref.read(notificationActionsProvider);
        final isUnread = notification.isRead == false;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.08),
              child: Icon(
                _iconForType(notification.type),
                color: Colors.blue,
                size: 20,
              ),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                color: AppTheme.deepNavy,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                notification.message,
                style: TextStyle(color: AppTheme.textPrimary.withOpacity(0.9)),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDateTime(notification.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                if (isUnread)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 8, color: Colors.red),
                  ),
              ],
            ),
            onTap: () async {
              if (isUnread) {
                await actions.markAsRead(notification.id);
              }
            },
          ),
        );
      },
    );
  }

  void _handleNotificationTap(
      BuildContext context, SupabaseNotificationModel notification) {
    // Handle navigation based on notification type
    switch (notification.type) {
      case 'game_assigned':
      case 'game_accepted':
      case 'game_declined':
        final gameId = notification.deepLinkData?['game_id'] as String?;
        if (gameId != null) {
          // Navigate to game details
          // Navigator.of(context).pushNamed('/game/$gameId');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigate to game: $gameId')),
          );
        }
        break;
      case 'checkin_success':
        // Navigate to check-in history or game details
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigate to check-in details')),
        );
        break;
      case 'payout_completed':
        // Navigate to earnings/payout history
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigate to earnings')),
        );
        break;
      case 'payout_requested':
      case 'payout_approved':
      case 'payout_failed':
        // Navigate to payout details or earnings page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigate to payout details')),
        );
        break;
      case 'system_message':
        // Show detailed message or navigate to settings
        _showNotificationDetails(context, notification.title,
            notification.message, notification.createdAt);
        break;
      default:
        break;
    }
  }

  void _showNotificationDetails(
      BuildContext context, String title, String message, DateTime createdAt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Text(
              'Received: ${_formatDateTime(createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'game_created':
        return Icons.new_releases_outlined;
      case 'game_assigned':
        return Icons.assignment_turned_in_outlined;
      case 'game_accepted':
        return Icons.check_circle_outline;
      case 'game_declined':
        return Icons.cancel_outlined;
      case 'game_reminder':
        return Icons.alarm_on_outlined;
      case 'checkin_success':
        return Icons.verified_outlined;
      case 'payout_requested':
        return Icons.request_quote_outlined;
      case 'payout_approved':
      case 'payout_completed':
        return Icons.payments_outlined;
      case 'payout_failed':
        return Icons.error_outline;
      case 'system_message':
      default:
        return Icons.notifications_none;
    }
  }
}

/// Notification icon with badge for app bar
class NotificationIconWithBadge extends ConsumerWidget {
  final VoidCallback? onTap;

  const NotificationIconWithBadge({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Stack(
      children: [
        IconButton(
          onPressed: onTap ??
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationsPage(),
                  ),
                );
              },
          icon: const Icon(Icons.notifications),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: const EdgeInsets.all(8),
          tooltip: 'Notifications',
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
