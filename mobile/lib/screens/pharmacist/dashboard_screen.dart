import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_paths.dart';
import '../../core/utils/formatters.dart';
import '../../providers/alert_providers.dart';
import '../../providers/inventory_providers.dart';
import '../../providers/prescription_providers.dart';
import '../../providers/report_providers.dart';
import '../../widgets/stat_card.dart';

class PharmacistDashboardScreen extends ConsumerWidget {
  const PharmacistDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(prescriptionQueueProvider);
    final alertsAsync = ref.watch(activeAlertsProvider);
    final lowStockAsync = ref.watch(lowStockInventoryProvider);
    final summaryAsync = ref.watch(salesSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('لوحة الصيدلاني')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(prescriptionQueueProvider);
          ref.invalidate(activeAlertsProvider);
          ref.invalidate(lowStockInventoryProvider);
          ref.invalidate(salesSummaryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('نظرة عامة على الوصفات والمخزون والتنبيهات', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                StatCard(
                  icon: Icons.fact_check_outlined,
                  label: 'بانتظار المراجعة',
                  value: queueAsync.maybeWhen(data: (d) => '${d.length}', orElse: () => '—'),
                  onTap: () => context.go(RoutePaths.pharmacistQueue),
                ),
                StatCard(
                  icon: Icons.notifications_active_outlined,
                  label: 'تنبيهات نشطة',
                  value: alertsAsync.maybeWhen(data: (d) => '${d.length}', orElse: () => '—'),
                  color: const Color(0xFFD97706),
                  onTap: () => context.go(RoutePaths.pharmacistAlerts),
                ),
                StatCard(
                  icon: Icons.inventory_2_outlined,
                  label: 'مخزون منخفض',
                  value: lowStockAsync.maybeWhen(data: (d) => '${d.length}', orElse: () => '—'),
                  color: const Color(0xFFDC2626),
                  onTap: () => context.go(RoutePaths.pharmacistInventory),
                ),
                StatCard(
                  icon: Icons.trending_up_rounded,
                  label: 'إيرادات 30 يومًا',
                  value: summaryAsync.maybeWhen(data: (d) => Formatters.currency(d.totalRevenue), orElse: () => '—'),
                  color: const Color(0xFF1F9D6A),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
