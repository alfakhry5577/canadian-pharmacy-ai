import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'core/notifications/push_notification_service.dart';
import 'providers/core_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is optional at this stage: `lib/firebase_options.dart` ships as a
  // placeholder (see its header comment) until `flutterfire configure` is run
  // with a real project. We never let a missing/invalid Firebase config crash
  // app startup — push notifications simply stay disabled until configured.
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    firebaseReady = true;
  } catch (error) {
    debugPrint('Firebase not configured yet — push notifications disabled. ($error)');
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: RoshettaApp(firebaseReady: firebaseReady),
    ),
  );
}
