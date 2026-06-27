import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/notification_model.dart';
import '../../providers/core_providers.dart';
import '../../providers/notification_providers.dart';
import '../../widgets/empty_error_states.dart';
import '../../widgets/skeleton_loader.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(myNotificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myNotificationsProvider);
          ref.invalidate(unreadNotificationCountProvider);
        },
        child: notificationsAsync.when(
          loading: () => const Padding(padding: EdgeInsets.all(16), child: SkeletonCardList(count: 5, cardHeight: 70)),
          error: (e, _) => ErrorStateWidget(message: '$e', onRetry: () => ref.invalidate(myNotificationsProvider)),
          data: (notifications) {
            if (notifications.isEmpty) {
              return const EmptyStateWidget(icon: Icons.notifications_none_rounded, title: 'لا توجد إشعارات');
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _NotificationTile(notification: notifications[i]),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});
  final NotificationModel notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      color: notification.isRead ? null : theme.colorScheme.primary.withValues(alpha: 0.05),
      child: ListTile(
        leading: Icon(
          notification.isRead ? Icons.mail_outline_rounded : Icons.markunread_rounded,
          color: notification.isRead ? theme.colorScheme.outline : theme.colorScheme.primary,
        ),
        title: Text(notification.subject, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 4),
            Text(Formatters.dateTime(notification.createdAt), style: theme.textTheme.bodySmall),
          ],
        ),
        isThreeLine: true,
        onTap: () async {
          if (!notification.isRead) {
            await ref.read(notificationRepositoryProvider).markRead(notification.id);
            ref.invalidate(myNotificationsProvider);
            ref.invalidate(unreadNotificationCountProvider);
          }
        },
      ),
    );
  }
}
