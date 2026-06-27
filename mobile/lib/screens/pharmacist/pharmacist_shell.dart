import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_paths.dart';

class PharmacistShell extends StatelessWidget {
  const PharmacistShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    RoutePaths.pharmacistDashboard,
    RoutePaths.pharmacistQueue,
    RoutePaths.pharmacistInventory,
    RoutePaths.pharmacistAlerts,
    RoutePaths.pharmacistChat,
  ];

  int _indexFor(String location) {
    final index = _tabs.indexWhere((tab) => location.startsWith(tab));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _indexFor(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => context.go(_tabs[index]),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check_rounded), label: 'المراجعة'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2_rounded), label: 'المخزون'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications_rounded), label: 'التنبيهات'),
          NavigationDestination(icon: Icon(Icons.smart_toy_outlined), selectedIcon: Icon(Icons.smart_toy_rounded), label: 'المساعد'),
        ],
      ),
    );
  }
}
