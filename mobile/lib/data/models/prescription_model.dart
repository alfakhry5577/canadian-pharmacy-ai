import 'package:equatable/equatable.dart';

enum PrescriptionStatus { pending, analyzed, reviewed, dispensed, rejected }

PrescriptionStatus prescriptionStatusFromString(String value) {
  return PrescriptionStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => PrescriptionStatus.pending,
  );
}

class SafetyFlagModel extends Equatable {
  final String type;
  final String severity; // info | warning | critical
  final String messageAr;

  const SafetyFlagModel({required this.type, required this.severity, required this.messageAr});

  factory SafetyFlagModel.fromJson(Map<String, dynamic> json) => SafetyFlagModel(
        type: json['type'] as String,
        severity: json['severity'] as String,
        messageAr: json['message_ar'] as String,
      );

  @override
  List<Object?> get props => [type, severity, messageAr];
}

class PrescriptionItemModel extends Equatable {
  final int id;
  final String extractedMedicationName;
  final int? matchedMedicationId;
  final String? dosageText;
  final String? frequencyText;
  final String? durationText;
  final double confidenceScore;
  final bool pharmacistConfirmed;

  const PrescriptionItemModel({
    required this.id,
    required this.extractedMedicationName,
    required this.matchedMedicationId,
    required this.dosageText,
    required this.frequencyText,
    required this.durationText,
    required this.confidenceScore,
    required this.pharmacistConfirmed,
  });

  factory PrescriptionItemModel.fromJson(Map<String, dynamic> json) => PrescriptionItemModel(
        id: json['id'] as int,
        extractedMedicationName: json['extracted_medication_name'] as String,
        matchedMedicationId: json['matched_medication_id'] as int?,
        dosageText: json['dosage_text'] as String?,
        frequencyText: json['frequency_text'] as String?,
        durationText: json['duration_text'] as String?,
        confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0,
        pharmacistConfirmed: json['pharmacist_confirmed'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, extractedMedicationName, matchedMedicationId, dosageText, frequencyText, durationText, confidenceScore, pharmacistConfirmed];
}

class PrescriptionModel extends Equatable {
  final int id;
  final int customerId;
  final int? pharmacistId;
  final String imagePath;
  final String? rawOcrText;
  final PrescriptionStatus status;
  final String? pharmacistNotes;
  final String createdAt;
  final String? reviewedAt;
  final List<PrescriptionItemModel> items;

  const PrescriptionModel({
    required this.id,
    required this.customerId,
    required this.pharmacistId,
    required this.imagePath,
    required this.rawOcrText,
    required this.status,
    required this.pharmacistNotes,
    required this.createdAt,
    required this.reviewedAt,
    required this.items,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) => PrescriptionModel(
        id: json['id'] as int,
        customerId: json['customer_id'] as int,
        pharmacistId: json['pharmacist_id'] as int?,
        imagePath: json['image_path'] as String,
        rawOcrText: json['raw_ocr_text'] as String?,
        status: prescriptionStatusFromString(json['status'] as String),
        pharmacistNotes: json['pharmacist_notes'] as String?,
        createdAt: json['created_at'] as String,
        reviewedAt: json['reviewed_at'] as String?,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => PrescriptionItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [id, customerId, pharmacistId, imagePath, status, createdAt, items];
}

class PrescriptionAnalysisResultModel extends Equatable {
  final PrescriptionModel prescription;
  final List<SafetyFlagModel> safetyFlags;
  final String disclaimerAr;

  const PrescriptionAnalysisResultModel({
    required this.prescription,
    required this.safetyFlags,
    required this.disclaimerAr,
  });

  factory PrescriptionAnalysisResultModel.fromJson(Map<String, dynamic> json) => PrescriptionAnalysisResultModel(
        prescription: PrescriptionModel.fromJson(json['prescription'] as Map<String, dynamic>),
        safetyFlags: (json['safety_flags'] as List<dynamic>? ?? [])
            .map((e) => SafetyFlagModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        disclaimerAr: json['disclaimer_ar'] as String,
      );

  @override
  List<Object?> get props => [prescription, safetyFlags, disclaimerAr];
}
