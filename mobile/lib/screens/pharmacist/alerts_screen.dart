import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../providers/alert_providers.dart';
import '../../providers/core_providers.dart';
import '../../widgets/empty_error_states.dart';
import '../../widgets/safety_callout.dart';
import '../../widgets/skeleton_loader.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(activeAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التنبيهات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'فحص المخزون الآن',
            onPressed: () async {
              await ref.read(alertRepositoryProvider).scan();
              ref.invalidate(activeAlertsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(activeAlertsProvider),
        child: alertsAsync.when(
          loading: () => const Padding(padding: EdgeInsets.all(16), child: SkeletonCardList(count: 4, cardHeight: 80)),
          error: (e, _) => ErrorStateWidget(message: '$e', onRetry: () => ref.invalidate(activeAlertsProvider)),
          data: (alerts) {
            if (alerts.isEmpty) {
              return const EmptyStateWidget(icon: Icons.notifications_off_outlined, title: 'لا توجد تنبيهات نشطة', description: 'كل شيء تحت السيطرة حاليًا.');
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final alert = alerts[i];
                return Dismissible(
                  key: ValueKey(alert.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.check_rounded, color: Colors.green),
                  ),
                  onDismissed: (_) => ref.read(alertRepositoryProvider).resolve(alert.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SafetyCallout(severity: calloutSeverityFromString(alert.severity), message: alert.messageAr),
                      Padding(
                        padding: const EdgeInsets.only(top: 4, right: 4),
                        child: Text(Formatters.dateTime(alert.createdAt), style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
