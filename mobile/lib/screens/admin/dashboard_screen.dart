import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../providers/alert_providers.dart';
import '../../providers/report_providers.dart';
import '../../widgets/empty_error_states.dart';
import '../../widgets/safety_callout.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/stat_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(salesSummaryProvider);
    final alertsAsync = ref.watch(activeAlertsProvider);
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(salesSummaryProvider);
        ref.invalidate(activeAlertsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('مؤشرات حقيقية من نظام المبيعات والمخزون والتنبيهات', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          summaryAsync.when(
            loading: () => const SkeletonCardList(count: 2, cardHeight: 64),
            error: (e, _) => ErrorStateWidget(message: '$e'),
            data: (summary) => GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                StatCard(icon: Icons.attach_money_rounded, label: 'الإيرادات (${summary.periodLabel})', value: Formatters.currency(summary.totalRevenue)),
                StatCard(icon: Icons.shopping_bag_outlined, label: 'عدد الطلبات', value: '${summary.totalOrders}', color: const Color(0xFF2563EB)),
                StatCard(icon: Icons.inventory_2_outlined, label: 'مخزون منخفض', value: '${summary.lowStockCount}', color: const Color(0xFFD97706)),
                StatCard(icon: Icons.warning_amber_rounded, label: 'دفعات قاربت الانتهاء', value: '${summary.expiringSoonCount}', color: const Color(0xFFDC2626)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('أحدث التنبيهات', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          alertsAsync.when(
            loading: () => const SkeletonCardList(count: 3, cardHeight: 60),
            error: (e, _) => ErrorStateWidget(message: '$e'),
            data: (alerts) {
              if (alerts.isEmpty) return const Text('لا توجد تنبيهات نشطة حاليًا.');
              return Column(
                children: alerts
                    .take(5)
                    .map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SafetyCallout(severity: calloutSeverityFromString(a.severity), message: a.messageAr),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
