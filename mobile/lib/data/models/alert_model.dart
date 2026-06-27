import 'package:equatable/equatable.dart';

class AlertModel extends Equatable {
  final int id;
  final String type;
  final String severity;
  final int? relatedMedicationId;
  final int? relatedPrescriptionId;
  final int? customerId;
  final String messageAr;
  final bool isResolved;
  final String createdAt;

  const AlertModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.relatedMedicationId,
    required this.relatedPrescriptionId,
    required this.customerId,
    required this.messageAr,
    required this.isResolved,
    required this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
        id: json['id'] as int,
        type: json['type'] as String,
        severity: json['severity'] as String,
        relatedMedicationId: json['related_medication_id'] as int?,
        relatedPrescriptionId: json['related_prescription_id'] as int?,
        customerId: json['customer_id'] as int?,
        messageAr: json['message_ar'] as String,
        isResolved: json['is_resolved'] as bool? ?? false,
        createdAt: json['created_at'] as String,
      );

  @override
  List<Object?> get props => [id, type, severity, messageAr, isResolved, createdAt];
}
