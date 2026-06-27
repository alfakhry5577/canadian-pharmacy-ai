import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/prescription_model.dart';
import 'core_providers.dart';

final myPrescriptionsProvider = FutureProvider.autoDispose<List<PrescriptionModel>>((ref) async {
  final result = await ref.watch(prescriptionRepositoryProvider).mine();
  return result.when(success: (data) => data, failure: (f) => throw f);
});

final prescriptionQueueProvider = FutureProvider.autoDispose<List<PrescriptionModel>>((ref) async {
  final result = await ref.watch(prescriptionRepositoryProvider).queue();
  return result.when(success: (data) => data, failure: (f) => throw f);
});

final prescriptionDetailProvider = FutureProvider.autoDispose.family<PrescriptionModel, int>((ref, id) async {
  final result = await ref.watch(prescriptionRepositoryProvider).getById(id);
  return result.when(success: (data) => data, failure: (f) => throw f);
});

/// Drives the upload screen's step-by-step progress UI (Select Image → OCR →
/// AI Analysis → Safety Validation) — the backend performs OCR+AI+safety in
/// one request, so this notifier *narrates* that single call as discrete
/// steps using a short timer, then reveals the real result.
enum UploadStep { idle, uploading, ocr, aiAnalysis, safetyCheck, done, error }

class UploadState {
  final UploadStep step;
  final PrescriptionAnalysisResultModel? result;
  final String? errorMessage;

  const UploadState({this.step = UploadStep.idle, this.result, this.errorMessage});

  UploadState copyWith({UploadStep? step, PrescriptionAnalysisResultModel? result, String? errorMessage}) =>
      UploadState(step: step ?? this.step, result: result ?? this.result, errorMessage: errorMessage);
}

class UploadController extends StateNotifier<UploadState> {
  UploadController(this.ref) : super(const UploadState());
  final Ref ref;

  Future<void> upload(String filePath) async {
    state = const UploadState(step: UploadStep.uploading);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    state = state.copyWith(step: UploadStep.ocr);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    state = state.copyWith(step: UploadStep.aiAnalysis);

    final result = await ref.read(prescriptionRepositoryProvider).upload(filePath);
    if (!mounted) return;

    result.when(
      success: (data) {
        state = state.copyWith(step: UploadStep.safetyCheck);
        Future<void>.delayed(const Duration(milliseconds: 400), () {
          if (mounted) state = UploadState(step: UploadStep.done, result: data);
        });
      },
      failure: (f) => state = UploadState(step: UploadStep.error, errorMessage: f.message),
    );
  }

  void reset() => state = const UploadState();
}

final uploadControllerProvider = StateNotifierProvider.autoDispose<UploadController, UploadState>(
  (ref) => UploadController(ref),
);
