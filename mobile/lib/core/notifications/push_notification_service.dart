import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'local_notification_service.dart';

/// Top-level (NOT a class method) background handler — required by the
/// firebase_messaging plugin contract; runs in its own isolate when a data
/// message arrives while the app is fully backgrounded/terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Keep this minimal: no UI, no Riverpod context available here.
  if (kDebugMode) {
    debugPrint('[FCM background] ${message.messageId}: ${message.data}');
  }
}

/// Notification "type" values the backend is expected to send in the FCM
/// data payload — used to deep-link on tap. Kept in sync with the four
/// categories requested: prescription updates, reminders, inventory alerts,
/// loyalty rewards.
enum PushNotificationType { prescriptionUpdate, reminder, inventoryAlert, loyaltyReward, generic }

PushNotificationType _typeFromString(String? value) {
  switch (value) {
    case 'prescription_update':
      return PushNotificationType.prescriptionUpdate;
    case 'reminder':
      return PushNotificationType.reminder;
    case 'inventory_alert':
      return PushNotificationType.inventoryAlert;
    case 'loyalty_reward':
      return PushNotificationType.loyaltyReward;
    default:
      return PushNotificationType.generic;
  }
}

class PushNotificationService {
  PushNotificationService({required this.onNotificationTapped});

  /// Called with the parsed (type, data) when the user taps a notification —
  /// wired up in app_router.dart to deep-link to the right screen.
  final void Function(PushNotificationType type, Map<String, dynamic> data) onNotificationTapped;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<String?> init() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    await LocalNotificationService.instance.init(
      onTapped: (payload) {
        if (payload == null) return;
        final data = jsonDecode(payload) as Map<String, dynamic>;
        onNotificationTapped(_typeFromString(data['type'] as String?), data);
      },
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedFromBackground);

    // App was opened by tapping a notification while fully terminated.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleOpenedFromBackground(initialMessage);
    }

    return _messaging.getToken();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      LocalNotificationService.instance.show(
        title: notification.title ?? 'روشتة AI',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleOpenedFromBackground(RemoteMessage message) {
    onNotificationTapped(_typeFromString(message.data['type'] as String?), message.data);
  }

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
