import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/router/route_paths.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/push_notification_service.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/core_providers.dart';
import 'providers/theme_locale_providers.dart';

class RoshettaApp extends ConsumerStatefulWidget {
  const RoshettaApp({super.key, required this.firebaseReady});
  final bool firebaseReady;

  @override
  ConsumerState<RoshettaApp> createState() => _RoshettaAppState();
}

class _RoshettaAppState extends ConsumerState<RoshettaApp> {
  PushNotificationService? _pushService;

  @override
  void initState() {
    super.initState();
    if (widget.firebaseReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initPush());
    }
  }

  Future<void> _initPush() async {
    _pushService = PushNotificationService(onNotificationTapped: _handleNotificationTap);
    final token = await _pushService!.init();
    if (token != null) {
      // Best-effort: silently no-ops until the backend exposes this route (see README).
      await ref.read(notificationRepositoryProvider).registerDeviceToken(token);
    }
    _pushService!.onTokenRefresh.listen((newToken) {
      ref.read(notificationRepositoryProvider).registerDeviceToken(newToken);
    });
  }

  void _handleNotificationTap(PushNotificationType type, Map<String, dynamic> data) {
    final router = ref.read(routerProvider);
    switch (type) {
      case PushNotificationType.prescriptionUpdate:
        final id = data['prescription_id'];
        if (id != null) router.push(RoutePaths.customerPrescriptionDetail(int.parse(id.toString())));
        break;
      case PushNotificationType.reminder:
        router.push(RoutePaths.customerReminders);
        break;
      case PushNotificationType.inventoryAlert:
        router.push(RoutePaths.pharmacistAlerts);
        break;
      case PushNotificationType.loyaltyReward:
        router.push(RoutePaths.customerLoyalty);
        break;
      case PushNotificationType.generic:
        router.push(RoutePaths.customerNotifications);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bootstraps auth state once at the root so the router's redirect logic has it ready.
    ref.watch(authProvider);

    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'روشتة AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        // Force RTL/LTR based on the active locale regardless of device default,
        // and clamp text scaling so custom layouts stay stable on accessibility settings.
        return Directionality(
          textDirection: locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
