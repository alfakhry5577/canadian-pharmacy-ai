import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_paths.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  static const _items = [
    (RoutePaths.adminDashboard, Icons.dashboard_outlined, 'نظرة عامة'),
    (RoutePaths.adminReports, Icons.bar_chart_outlined, 'التقارير'),
    (RoutePaths.adminInventory, Icons.inventory_2_outlined, 'المخزون'),
    (RoutePaths.adminUsers, Icons.people_outline, 'المستخدمون'),
    (RoutePaths.adminAuditLogs, Icons.history_outlined, 'سجل التدقيق'),
    (RoutePaths.adminAiMonitoring, Icons.smart_toy_outlined, 'مراقبة AI'),
    (RoutePaths.adminSettings, Icons.settings_outlined, 'الإعدادات'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      appBar: AppBar(
        title: Text(_items.firstWhere((i) => location.startsWith(i.$1), orElse: () => _items.first).$3),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('بوابة الإدارة', style: Theme.of(context).textTheme.titleLarge),
              ),
              ..._items.map((item) {
                final selected = location.startsWith(item.$1);
                return ListTile(
                  leading: Icon(item.$2),
                  title: Text(item.$3),
                  selected: selected,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go(item.$1);
                  },
                );
              }),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('تسجيل الخروج'),
                onTap: () => ref.read(authProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}
