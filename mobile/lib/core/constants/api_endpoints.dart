/// API base URL. Override at build time with:
///   flutter build apk --dart-define=API_BASE_URL=https://api.yourdomain.com
/// Defaults to the Android emulator's loopback alias to the host machine,
/// which is what `http://localhost:8000` on your dev machine maps to.
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);

class StorageKeys {
  StorageKeys._();
  static const String accessToken = 'roshetta_access_token';
  static const String cachedUser = 'roshetta_cached_user';
  static const String localeCode = 'roshetta_locale_code';
  static const String themeMode = 'roshetta_theme_mode';
}

class ApiPaths {
  ApiPaths._();

  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String me = '/api/auth/me';
  static const String addAllergy = '/api/auth/me/allergies';
  static const String addChronicCondition = '/api/auth/me/chronic-conditions';

  static const String medicationSearch = '/api/medications/search';
  static String medicationDetail(int id) => '/api/medications/$id';
  static const String medicationCreate = '/api/medications';

  static const String prescriptionUpload = '/api/prescriptions/upload';
  static const String prescriptionsMine = '/api/prescriptions/mine';
  static const String prescriptionsQueue = '/api/prescriptions/queue';
  static String prescriptionDetail(int id) => '/api/prescriptions/$id';
  static String prescriptionItemUpdate(int itemId) => '/api/prescriptions/items/$itemId';
  static String prescriptionReview(int id) => '/api/prescriptions/$id/review';

  static const String inventory = '/api/inventory';
  static const String inventoryLowStock = '/api/inventory/low-stock';
  static String inventoryAddBatch(int medicationId) => '/api/inventory/$medicationId';
  static String inventoryUpdate(int itemId) => '/api/inventory/$itemId';

  static const String alerts = '/api/alerts';
  static const String alertsScan = '/api/alerts/scan';
  static const String remindersScan = '/api/alerts/reminders-scan';
  static String alertResolve(int id) => '/api/alerts/$id/resolve';

  static const String chatSend = '/api/chat/send';
  static String chatHistory(int sessionId) => '/api/chat/$sessionId/history';

  static const String salesSummary = '/api/reports/sales-summary';

  static const String customerReminders = '/api/customer/reminders';
  static String customerReminderDelete(int id) => '/api/customer/reminders/$id';
  static const String customerLoyalty = '/api/customer/loyalty';

  static const String notificationsMine = '/api/notifications/mine';
  static const String notificationsUnreadCount = '/api/notifications/unread-count';
  static String notificationMarkRead(int id) => '/api/notifications/$id/read';

  /// NOT YET IMPLEMENTED on the backend — see mobile/README.md "Known Gaps".
  /// Suggested route to add server-side: POST /api/notifications/device-token
  static const String registerDeviceToken = '/api/notifications/device-token';
}
