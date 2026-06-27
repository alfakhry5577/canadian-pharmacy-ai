import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../providers/report_providers.dart';
import '../../widgets/empty_error_states.dart';
import '../../widgets/skeleton_loader.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(salesSummaryDaysProvider);
    final summaryAsync = ref.watch(salesSummaryProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 7, label: Text('7 أيام')),
            ButtonSegment(value: 30, label: Text('30 يومًا')),
            ButtonSegment(value: 90, label: Text('90 يومًا')),
          ],
          selected: {days},
          onSelectionChanged: (s) => ref.read(salesSummaryDaysProvider.notifier).state = s.first,
        ),
        const SizedBox(height: 20),
        summaryAsync.when(
          loading: () => const SkeletonCardList(count: 4, cardHeight: 60),
          error: (e, _) => ErrorStateWidget(message: '$e', onRetry: () => ref.invalidate(salesSummaryProvider)),
          data: (summary) {
            if (summary.topMedications.isEmpty) {
              return const Text('لا توجد بيانات مبيعات كافية في هذه الفترة بعد.');
            }
            final maxQty = summary.topMedications.map((m) => m.totalQuantitySold).reduce((a, b) => a > b ? a : b);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('أكثر الأدوية طلبًا', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                ...summary.topMedications.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(m.nameAr, style: theme.textTheme.bodyMedium)),
                              Text(Formatters.currency(m.totalRevenue), style: theme.textTheme.bodySmall),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(value: m.totalQuantitySold / maxQty, minHeight: 8),
                          ),
                          const SizedBox(height: 2),
                          Text('${m.totalQuantitySold} وحدة', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    )),
              ],
            );
          },
        ),
      ],
    );
  }
}
