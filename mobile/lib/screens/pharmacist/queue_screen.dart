import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_paths.dart';
import '../../core/utils/formatters.dart';
import '../../providers/prescription_providers.dart';
import '../../widgets/empty_error_states.dart';
import '../../widgets/skeleton_loader.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(prescriptionQueueProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('مراجعة الوصفات')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(prescriptionQueueProvider),
        child: queueAsync.when(
          loading: () => const Padding(padding: EdgeInsets.all(16), child: SkeletonCardList(count: 4)),
          error: (e, _) => ErrorStateWidget(message: '$e', onRetry: () => ref.invalidate(prescriptionQueueProvider)),
          data: (queue) {
            if (queue.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.fact_check_outlined,
                title: 'لا توجد وصفات بانتظار المراجعة',
                description: 'عمل رائع! قائمة الانتظار فارغة حاليًا.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: queue.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final p = queue[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text('وصفة #${p.id} — زبون #${p.customerId}'),
                    subtitle: Text('رُفعت في ${Formatters.dateTime(p.createdAt)} · ${p.items.length} بند'),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () => context.push(RoutePaths.pharmacistQueueDetail(p.id)),
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
