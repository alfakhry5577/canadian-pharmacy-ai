import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/router/route_paths.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/prescription_model.dart';
import '../../providers/prescription_providers.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/safety_callout.dart';

class PrescriptionUploadScreen extends ConsumerStatefulWidget {
  const PrescriptionUploadScreen({super.key});

  @override
  ConsumerState<PrescriptionUploadScreen> createState() => _PrescriptionUploadScreenState();
}

class _PrescriptionUploadScreenState extends ConsumerState<PrescriptionUploadScreen> {
  String? _imagePath;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    setState(() => _imagePath = picked.path);
    await ref.read(uploadControllerProvider.notifier).upload(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('رفع وتحليل وصفة طبية')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: uploadState.step == UploadStep.done && uploadState.result != null
              ? _ResultView(result: uploadState.result!)
              : _UploadView(imagePath: _imagePath, state: uploadState, onPickImage: _pickImage),
        ),
      ),
    );
  }
}

class _UploadView extends StatelessWidget {
  const _UploadView({required this.imagePath, required this.state, required this.onPickImage});
  final String? imagePath;
  final UploadState state;
  final Future<void> Function(ImageSource) onPickImage;

  bool get _isBusy => state.step != UploadStep.idle && state.step != UploadStep.error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              if (imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(File(imagePath!), height: 200, fit: BoxFit.cover),
                )
              else
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.document_scanner_outlined, size: 36, color: theme.colorScheme.primary),
                ),
              const SizedBox(height: 16),
              Text('صوّر وصفتك أو اختر صورة من المعرض', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
              Text('يُفضّل صورة واضحة بإضاءة جيدة', style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'تصوير',
                      icon: Icons.camera_alt_outlined,
                      isLoading: _isBusy,
                      onPressed: () => onPickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'المعرض',
                      icon: Icons.photo_library_outlined,
                      outlined: true,
                      isLoading: _isBusy,
                      onPressed: () => onPickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_isBusy) ...[const SizedBox(height: 28), _ProgressSteps(currentStep: state.step)],
        if (state.step == UploadStep.error) ...[
          const SizedBox(height: 20),
          SafetyCallout(severity: CalloutSeverity.critical, message: state.errorMessage ?? 'حدث خطأ غير متوقع'),
        ],
      ],
    );
  }
}

class _ProgressSteps extends StatelessWidget {
  const _ProgressSteps({required this.currentStep});
  final UploadStep currentStep;

  static const _steps = [
    (UploadStep.uploading, Icons.cloud_upload_outlined, 'رفع الصورة'),
    (UploadStep.ocr, Icons.document_scanner_outlined, 'استخراج النص (OCR)'),
    (UploadStep.aiAnalysis, Icons.auto_awesome_outlined, 'تحليل الذكاء الاصطناعي'),
    (UploadStep.safetyCheck, Icons.health_and_safety_outlined, 'فحوصات السلامة'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = _steps.indexWhere((s) => s.$1 == currentStep);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _steps.asMap().entries.map((entry) {
        final i = entry.key;
        final (_, icon, label) = entry.value;
        final isDone = i < currentIndex;
        final isCurrent = i == currentIndex;
        final color = isDone || isCurrent ? theme.colorScheme.primary : theme.colorScheme.outlineVariant;

        return Expanded(
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color.withValues(alpha: isCurrent || isDone ? 1 : 0.15), shape: BoxShape.circle),
                child: isCurrent
                    ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                    : Icon(isDone ? Icons.check_rounded : icon, color: isDone ? Colors.white : color, size: 18),
              ),
              const SizedBox(height: 6),
              Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center, maxLines: 2),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ResultView extends ConsumerWidget {
  const _ResultView({required this.result});
  final PrescriptionAnalysisResultModel result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prescription = result.prescription;
    final flags = result.safetyFlags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SafetyCallout(
          severity: CalloutSeverity.info,
          title: 'تم رفع الوصفة بنجاح',
          message: 'بانتظار مراجعة الصيدلاني واعتمادها قبل الصرف النهائي.',
        ),
        const SizedBox(height: 20),
        Text('البنود المستخرجة', style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        if (prescription.items.isEmpty)
          const Text('لم يتمكن النظام من استخراج بنود واضحة من الصورة. سيراجع الصيدلاني الصورة الأصلية مباشرة.')
        else
          ...prescription.items.map<Widget>((item) => _ItemTile(item: item)),
        const SizedBox(height: 20),
        Text('فحوصات السلامة', style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        if (flags.isEmpty)
          const SafetyCallout(severity: CalloutSeverity.info, message: 'لم يرصد النظام تعارضات واضحة — مع ذلك تبقى مراجعة الصيدلاني ضرورية.')
        else
          ...flags.map<Widget>((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SafetyCallout(severity: calloutSeverityFromString(f.severity), message: f.messageAr),
              )),
        const SizedBox(height: 12),
        Text(result.disclaimerAr, style: theme.textTheme.bodySmall),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'عرض تفاصيل الوصفة',
          onPressed: () {
            ref.read(uploadControllerProvider.notifier).reset();
            context.pushReplacement(RoutePaths.customerPrescriptionDetail(prescription.id));
          },
        ),
        const SizedBox(height: 10),
        PrimaryButton(label: 'رفع وصفة أخرى', outlined: true, onPressed: () => ref.read(uploadControllerProvider.notifier).reset()),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});
  final PrescriptionItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = Formatters.confidencePercent(item.confidenceScore);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.extractedMedicationName, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                if (item.dosageText != null) Text('الجرعة: ${item.dosageText}', style: theme.textTheme.bodySmall),
                if (item.frequencyText != null) Text('التكرار: ${item.frequencyText}', style: theme.textTheme.bodySmall),
                if (item.durationText != null) Text('المدة: ${item.durationText}', style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(value: pct / 100, minHeight: 6),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$pct%', style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
