import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_paths.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/prescription_model.dart';
import '../../providers/prescription_providers.dart';
import '../../widgets/empty_error_states.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/status_badges.dart';

class PrescriptionHistoryScreen extends ConsumerWidget {
  const PrescriptionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionsAsync = ref.watch(myPrescriptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('وصفاتي الطبية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push(RoutePaths.customerPrescriptionUpload),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myPrescriptionsProvider),
        child: prescriptionsAsync.when(
          loading: () => const Padding(padding: EdgeInsets.all(16), child: SkeletonCardList(count: 4)),
          error: (e, _) => ErrorStateWidget(message: '$e', onRetry: () => ref.invalidate(myPrescriptionsProvider)),
          data: (prescriptions) {
            if (prescriptions.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.description_outlined,
                title: 'لا توجد وصفات مرفوعة بعد',
                description: 'ابدأ برفع صورة وصفتك الطبية الأولى.',
                action: PrimaryButton(
                  label: 'رفع وصفة',
                  onPressed: () => context.push(RoutePaths.customerPrescriptionUpload),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: prescriptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _PrescriptionTile(prescription: prescriptions[i]),
            );
          },
        ),
      ),
    );
  }
}

class _PrescriptionTile extends StatelessWidget {
  const _PrescriptionTile({required this.prescription});
  final PrescriptionModel prescription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push(RoutePaths.customerPrescriptionDetail(prescription.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.description_outlined, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('وصفة #${prescription.id}', style: theme.textTheme.titleMedium),
                    Text(
                      '${Formatters.dateTime(prescription.createdAt)} · ${prescription.items.length} بند',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusBadge(status: prescription.status),
            ],
          ),
        ),
      ),
    );
  }
}
