class RoutePaths {
  RoutePaths._();

  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  // Customer
  static const customerRoot = '/customer';
  static const customerDashboard = '/customer/dashboard';
  static const customerSearch = '/customer/search';
  static const customerPrescriptions = '/customer/prescriptions';
  static const customerPrescriptionUpload = '/customer/prescriptions/upload';
  static String customerPrescriptionDetail(int id) => '/customer/prescriptions/$id';
  static const customerReminders = '/customer/reminders';
  static const customerLoyalty = '/customer/loyalty';
  static const customerChat = '/customer/chat';
  static const customerNotifications = '/customer/notifications';

  // Pharmacist
  static const pharmacistRoot = '/pharmacist';
  static const pharmacistDashboard = '/pharmacist/dashboard';
  static const pharmacistQueue = '/pharmacist/queue';
  static String pharmacistQueueDetail(int id) => '/pharmacist/queue/$id';
  static const pharmacistInventory = '/pharmacist/inventory';
  static const pharmacistAlerts = '/pharmacist/alerts';
  static const pharmacistChat = '/pharmacist/chat';

  // Admin
  static const adminRoot = '/admin';
  static const adminDashboard = '/admin/dashboard';
  static const adminReports = '/admin/reports';
  static const adminInventory = '/admin/inventory';
  static const adminUsers = '/admin/users';
  static const adminAuditLogs = '/admin/audit-logs';
  static const adminAiMonitoring = '/admin/ai-monitoring';
  static const adminSettings = '/admin/settings';
}
