import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/utils/formatters.dart';
import '../../providers/prescription_providers.dart';
import '../../widgets/empty_error_states.dart';
import '../../widgets/safety_callout.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/status_badges.dart';

String _prescriptionImageUrl(String imagePath) {
  final filename = imagePath.split(RegExp(r'[\\/]')).last;
  return '$kApiBaseUrl/uploads/$filename';
}

class PrescriptionDetailScreen extends ConsumerWidget {
  const PrescriptionDetailScreen({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionAsync = ref.watch(prescriptionDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: Text('وصفة #$id')),
      body: prescriptionAsync.when(
        loading: () => const Padding(padding: EdgeInsets.all(16), child: SkeletonCardList(count: 3)),
        error: (e, _) => ErrorStateWidget(message: '$e', onRetry: () => ref.invalidate(prescriptionDetailProvider(id))),
        data: (prescription) {
          final theme = Theme.of(context);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(prescriptionDetailProvider(id)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(Formatters.dateTime(prescription.createdAt), style: theme.textTheme.bodyMedium),
                    StatusBadge(status: prescription.status),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: _prescriptionImageUrl(prescription.imagePath),
                    placeholder: (context, _) => const SkeletonBox(height: 220),
                    errorWidget: (context, _, __) => Container(
                      height: 220,
                      color: theme.colorScheme.surfaceVariant,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
                if (prescription.pharmacistNotes != null) ...[
                  const SizedBox(height: 16),
                  SafetyCallout(title: 'ملاحظات الصيدلاني', message: prescription.pharmacistNotes!, severity: CalloutSeverity.info),
                ],
                const SizedBox(height: 20),
                Text('البنود المستخرجة', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                if (prescription.items.isEmpty)
                  const Text('لا توجد بنود مستخرجة لهذه الوصفة.')
                else
                  ...prescription.items.map(
                    (item) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.extractedMedicationName, style: theme.textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 16,
                              children: [
                                if (item.dosageText != null) Text('الجرعة: ${item.dosageText}', style: theme.textTheme.bodySmall),
                                if (item.frequencyText != null) Text('التكرار: ${item.frequencyText}', style: theme.textTheme.bodySmall),
                                if (item.durationText != null) Text('المدة: ${item.durationText}', style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
