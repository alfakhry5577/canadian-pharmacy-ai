import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/dio_client.dart';
import '../core/storage/cache_service.dart';
import '../core/storage/secure_storage_service.dart';

import '../data/services/auth_service.dart';
import '../data/services/medication_service.dart';
import '../data/services/prescription_service.dart';
import '../data/services/inventory_service.dart';
import '../data/services/alert_service.dart';
import '../data/services/chat_service.dart';
import '../data/services/report_service.dart';
import '../data/services/customer_service.dart';
import '../data/services/app_notification_service.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/medication_repository.dart';
import '../data/repositories/prescription_repository.dart';
import '../data/repositories/inventory_repository.dart';
import '../data/repositories/alert_repository.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/report_repository.dart';
import '../data/repositories/customer_repository.dart';
import '../data/repositories/notification_repository.dart';

import 'auth_provider.dart';

/// Overridden in main.dart with the real instance obtained via
/// `await SharedPreferences.getInstance()` before `runApp`.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService(ref.watch(sharedPreferencesProvider));
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    tokenGetter: () => ref.read(secureStorageProvider).readToken(),
    // Deferred read — only triggered on an actual 401, so no circular
    // construction happens when this provider itself is first built.
    onUnauthorized: () => ref.read(authProvider.notifier).handleUnauthorized(),
  );
});

final dioProvider = Provider<Dio>((ref) => ref.watch(dioClientProvider).dio);

// ---- Services ----
final authServiceProvider = Provider((ref) => AuthService(ref.watch(dioProvider)));
final medicationServiceProvider = Provider((ref) => MedicationService(ref.watch(dioProvider)));
final prescriptionServiceProvider = Provider((ref) => PrescriptionService(ref.watch(dioProvider)));
final inventoryServiceProvider = Provider((ref) => InventoryService(ref.watch(dioProvider)));
final alertServiceProvider = Provider((ref) => AlertService(ref.watch(dioProvider)));
final chatServiceProvider = Provider((ref) => ChatService(ref.watch(dioProvider)));
final reportServiceProvider = Provider((ref) => ReportService(ref.watch(dioProvider)));
final customerServiceProvider = Provider((ref) => CustomerService(ref.watch(dioProvider)));
final appNotificationServiceProvider = Provider((ref) => AppNotificationService(ref.watch(dioProvider)));

// ---- Repositories ----
final authRepositoryProvider = Provider((ref) => AuthRepository(ref.watch(authServiceProvider)));
final medicationRepositoryProvider = Provider(
  (ref) => MedicationRepository(ref.watch(medicationServiceProvider), ref.watch(cacheServiceProvider)),
);
final prescriptionRepositoryProvider = Provider(
  (ref) => PrescriptionRepository(ref.watch(prescriptionServiceProvider), ref.watch(cacheServiceProvider)),
);
final inventoryRepositoryProvider = Provider((ref) => InventoryRepository(ref.watch(inventoryServiceProvider)));
final alertRepositoryProvider = Provider((ref) => AlertRepository(ref.watch(alertServiceProvider)));
final chatRepositoryProvider = Provider((ref) => ChatRepository(ref.watch(chatServiceProvider)));
final reportRepositoryProvider = Provider((ref) => ReportRepository(ref.watch(reportServiceProvider)));
final customerRepositoryProvider = Provider((ref) => CustomerRepository(ref.watch(customerServiceProvider)));
final notificationRepositoryProvider = Provider(
  (ref) => NotificationRepository(ref.watch(appNotificationServiceProvider)),
);
