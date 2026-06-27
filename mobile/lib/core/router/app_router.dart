import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import 'route_paths.dart';

import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';

import '../../screens/customer/customer_shell.dart';
import '../../screens/customer/dashboard_screen.dart' as customer;
import '../../screens/customer/search_screen.dart';
import '../../screens/customer/prescription_history_screen.dart';
import '../../screens/customer/prescription_upload_screen.dart';
import '../../screens/customer/prescription_detail_screen.dart';
import '../../screens/customer/reminders_screen.dart';
import '../../screens/customer/loyalty_screen.dart';
import '../../screens/customer/chat_screen.dart' as customerChat;
import '../../screens/customer/notifications_screen.dart';

import '../../screens/pharmacist/pharmacist_shell.dart';
import '../../screens/pharmacist/dashboard_screen.dart' as pharmacist;
import '../../screens/pharmacist/queue_screen.dart';
import '../../screens/pharmacist/review_detail_screen.dart';
import '../../screens/pharmacist/inventory_screen.dart' as pharmacistInventory;
import '../../screens/pharmacist/alerts_screen.dart';
import '../../screens/pharmacist/chat_screen.dart' as pharmacistChat;

import '../../screens/admin/admin_shell.dart';
import '../../screens/admin/dashboard_screen.dart' as admin;
import '../../screens/admin/reports_screen.dart';
import '../../screens/admin/inventory_screen.dart' as adminInventory;
import '../../screens/admin/users_screen.dart';
import '../../screens/admin/audit_logs_screen.dart';
import '../../screens/admin/ai_monitoring_screen.dart';
import '../../screens/admin/settings_screen.dart';

String _homeFor(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return RoutePaths.adminDashboard;
    case UserRole.pharmacist:
      return RoutePaths.pharmacistDashboard;
    case UserRole.customer:
      return RoutePaths.customerDashboard;
  }
}

bool _isAuthRoute(String path) =>
    path == RoutePaths.login || path == RoutePaths.register || path == RoutePaths.forgotPassword;

bool _allowedForRole(String path, UserRole role) {
  if (path.startsWith(RoutePaths.adminRoot)) return role == UserRole.admin;
  if (path.startsWith(RoutePaths.pharmacistRoot)) return role == UserRole.pharmacist || role == UserRole.admin;
  if (path.startsWith(RoutePaths.customerRoot)) return role == UserRole.customer;
  return true;
}

final routerProvider = Provider<GoRouter>((ref) {
  // Watching the notifier (not just the state) ensures this provider doesn't
  // get disposed/recreated independently of auth lifecycle; the actual state
  // read happens fresh inside `redirect` below via ref.read(authProvider).
  ref.watch(authProvider.notifier);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final path = state.matchedLocation;

      if (auth.status == AuthStatus.bootstrapping) {
        return path == RoutePaths.splash ? null : RoutePaths.splash;
      }

      if (auth.status == AuthStatus.unauthenticated) {
        return _isAuthRoute(path) ? null : RoutePaths.login;
      }

      // Authenticated from here on.
      if (path == RoutePaths.splash || _isAuthRoute(path)) {
        return _homeFor(auth.user!.role);
      }
      if (!_allowedForRole(path, auth.user!.role)) {
        return _homeFor(auth.user!.role);
      }
      return null;
    },
    routes: [
      GoRoute(path: RoutePaths.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: RoutePaths.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: RoutePaths.register, builder: (context, state) => const RegisterScreen()),
      GoRoute(path: RoutePaths.forgotPassword, builder: (context, state) => const ForgotPasswordScreen()),

      // ---- Customer ----
      ShellRoute(
        builder: (context, state, child) => CustomerShell(child: child),
        routes: [
          GoRoute(path: RoutePaths.customerDashboard, builder: (context, state) => const customer.CustomerDashboardScreen()),
          GoRoute(path: RoutePaths.customerSearch, builder: (context, state) => const SearchScreen()),
          GoRoute(path: RoutePaths.customerPrescriptions, builder: (context, state) => const PrescriptionHistoryScreen()),
          GoRoute(path: RoutePaths.customerChat, builder: (context, state) => const customerChat.ChatScreen()),
        ],
      ),
      GoRoute(path: RoutePaths.customerPrescriptionUpload, builder: (context, state) => const PrescriptionUploadScreen()),
      GoRoute(
        path: '/customer/prescriptions/:id',
        builder: (context, state) => PrescriptionDetailScreen(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: RoutePaths.customerReminders, builder: (context, state) => const RemindersScreen()),
      GoRoute(path: RoutePaths.customerLoyalty, builder: (context, state) => const LoyaltyScreen()),
      GoRoute(path: RoutePaths.customerNotifications, builder: (context, state) => const NotificationsScreen()),

      // ---- Pharmacist ----
      ShellRoute(
        builder: (context, state, child) => PharmacistShell(child: child),
        routes: [
          GoRoute(path: RoutePaths.pharmacistDashboard, builder: (context, state) => const pharmacist.PharmacistDashboardScreen()),
          GoRoute(path: RoutePaths.pharmacistQueue, builder: (context, state) => const QueueScreen()),
          GoRoute(path: RoutePaths.pharmacistInventory, builder: (context, state) => const pharmacistInventory.PharmacistInventoryScreen()),
          GoRoute(path: RoutePaths.pharmacistAlerts, builder: (context, state) => const AlertsScreen()),
          GoRoute(path: RoutePaths.pharmacistChat, builder: (context, state) => const pharmacistChat.PharmacistChatScreen()),
        ],
      ),
      GoRoute(
        path: '/pharmacist/queue/:id',
        builder: (context, state) => ReviewDetailScreen(id: int.parse(state.pathParameters['id']!)),
      ),

      // ---- Admin ----
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: RoutePaths.adminDashboard, builder: (context, state) => const admin.AdminDashboardScreen()),
          GoRoute(path: RoutePaths.adminReports, builder: (context, state) => const ReportsScreen()),
          GoRoute(path: RoutePaths.adminInventory, builder: (context, state) => const adminInventory.AdminInventoryScreen()),
          GoRoute(path: RoutePaths.adminUsers, builder: (context, state) => const UsersScreen()),
          GoRoute(path: RoutePaths.adminAuditLogs, builder: (context, state) => const AuditLogsScreen()),
          GoRoute(path: RoutePaths.adminAiMonitoring, builder: (context, state) => const AiMonitoringScreen()),
          GoRoute(path: RoutePaths.adminSettings, builder: (context, state) => const SettingsScreen()),
        ],
      ),
    ],
  );
});

/// Bridges Riverpod state changes into something GoRouter's `refreshListenable`
/// understands, so navigation redirects re-evaluate the moment auth state changes.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authProvider, (previous, next) {
      if (previous?.status != next.status) notifyListeners();
    });
  }
}
