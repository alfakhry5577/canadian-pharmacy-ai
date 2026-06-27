import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/notification_model.dart';
import 'core_providers.dart';

final myNotificationsProvider = FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  final result = await ref.watch(notificationRepositoryProvider).mine();
  return result.when(success: (data) => data, failure: (f) => throw f);
});

final unreadNotificationCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final result = await ref.watch(notificationRepositoryProvider).unreadCount();
  return result.when(success: (data) => data, failure: (_) => 0);
});
