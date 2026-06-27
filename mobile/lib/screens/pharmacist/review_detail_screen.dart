import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/router/route_paths.dart';
import '../../data/models/prescription_model.dart';
import '../../providers/alert_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/prescription_providers.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_error_states.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/safety_callout.dart';
import '../../widgets/skeleton_loader.dart';

String _prescriptionImageUrl(String imagePath) {
  final filename = imagePath.split(RegExp(r'[\\/]')).last;
  return '$kApiBaseUrl/uploads/$filename';
}

class ReviewDetailScreen extends ConsumerStatefulWidget {
  const ReviewDetailScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends ConsumerState<ReviewDetailScreen> {
  final _notesController = TextEditingController();
  bool _isDeciding = false;

  Future<void> _decide(String status) async {
    setState(() => _isDeciding = true);
    final result = await ref.read(prescriptionRepositoryProvider).review(
          widget.id,
          status: status,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _isDeciding = false);
    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(status == 'reviewed' ? 'تم اعتماد الوصفة' : 'تم رفض الوصفة')),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RoutePaths.pharmacistQueue);
        }
      },
      failure: (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  Future<void> _editItem(PrescriptionItemModel item) async {
    final dosageCtrl = TextEditingController(text: item.dosageText ?? '');
    final freqCtrl = TextEditingController(text: item.frequencyText ?? '');
    final durationCtrl = TextEditingController(text: item.durationText ?? '');

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.extractedMedicationName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            AppTextField(label: 'الجرعة', controller: dosageCtrl),
            const SizedBox(height: 12),
            AppTextField(label: 'عدد المرات', controller: freqCtrl),
            const SizedBox(height: 12),
            AppTextField(label: 'المدة', controller: durationCtrl),
            const SizedBox(height: 20),
            PrimaryButton(label: 'حفظ', onPressed: () => Navigator.of(context).pop(true)),
          ],
        ),
      ),
    );

    if (saved == true) {
      await ref.read(prescriptionRepositoryProvider).updateItem(item.id, {
        'dosage_text': dosageCtrl.text,
        'frequency_text': freqCtrl.text,
        'duration_text': durationCtrl.text,
      });
      ref.invalidate(prescriptionDetailProvider(widget.id));
    }
  }

  Future<void> _confirmItem(PrescriptionItemModel item) async {
    await ref.read(prescriptionRepositoryProvider).updateItem(item.id, {'pharmacist_confirmed': true});
    ref.invalidate(prescriptionDetailProvider(widget.id));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prescriptionAsync = ref.watch(prescriptionDetailProvider(widget.id));
    final alertsAsync = ref.watch(activeAlertsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('مراجعة وصفة #${widget.id}')),
      body: prescriptionAsync.when(
        loading: () => const Padding(padding: EdgeInsets.all(16), child: SkeletonCardList(count: 3)),
        error: (e, _) => ErrorStateWidget(message: '$e', onRetry: () => ref.invalidate(prescriptionDetailProvider(widget.id))),
        data: (prescription) {
          final relatedAlerts = alertsAsync.maybeWhen(
            data: (alerts) => alerts.where((a) => a.relatedPrescriptionId == widget.id).toList(),
            orElse: () => [],
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: _prescriptionImageUrl(prescription.imagePath),
                  placeholder: (context, _) => const SkeletonBox(height: 220),
                  fit: BoxFit.contain,
                ),
              ),
              if (prescription.rawOcrText != null && prescription.rawOcrText!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ExpansionTile(
                  title: const Text('عرض النص الخام المستخرج (OCR)'),
                  tilePadding: EdgeInsets.zero,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
                      child: Text(prescription.rawOcrText!),
                    ),
                  ],
                ),
              ],
              if (relatedAlerts.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('تنبيهات السلامة لهذه الوصفة', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...relatedAlerts.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SafetyCallout(severity: calloutSeverityFromString(a.severity), message: a.messageAr),
                    )),
              ],
              const SizedBox(height: 16),
              Text('البنود المستخرجة (قابلة للتعديل)', style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              ...prescription.items.map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.extractedMedicationName, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Wrap(spacing: 14, children: [
                            Text('الجرعة: ${item.dosageText ?? "—"}', style: theme.textTheme.bodySmall),
                            Text('التكرار: ${item.frequencyText ?? "—"}', style: theme.textTheme.bodySmall),
                            Text('المدة: ${item.durationText ?? "—"}', style: theme.textTheme.bodySmall),
                          ]),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () => _editItem(item),
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: const Text('تعديل'),
                              ),
                              if (!item.pharmacistConfirmed)
                                TextButton.icon(
                                  onPressed: () => _confirmItem(item),
                                  icon: const Icon(Icons.check_circle_outline, size: 16),
                                  label: const Text('تأكيد'),
                                )
                              else
                                const Chip(label: Text('مؤكد', style: TextStyle(fontSize: 11)), visualDensity: VisualDensity.compact),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
              AppTextField(label: 'ملاحظات الصيدلاني (تُعرض للزبون)', controller: _notesController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: PrimaryButton(label: 'اعتماد', icon: Icons.check_circle_outline, isLoading: _isDeciding, onPressed: () => _decide('reviewed'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(label: 'رفض', icon: Icons.cancel_outlined, outlined: true, isLoading: _isDeciding, onPressed: () => _decide('rejected')),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
