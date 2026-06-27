import 'package:equatable/equatable.dart';

class ReminderModel extends Equatable {
  final int id;
  final int medicationId;
  final int frequencyDays;
  final String nextReminderDate;
  final bool isActive;

  const ReminderModel({
    required this.id,
    required this.medicationId,
    required this.frequencyDays,
    required this.nextReminderDate,
    required this.isActive,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(
        id: json['id'] as int,
        medicationId: json['medication_id'] as int,
        frequencyDays: json['frequency_days'] as int,
        nextReminderDate: json['next_reminder_date'] as String,
        isActive: json['is_active'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [id, medicationId, frequencyDays, nextReminderDate, isActive];
}

class LoyaltyAccountModel extends Equatable {
  final int id;
  final int customerId;
  final int points;
  final String tier;

  const LoyaltyAccountModel({required this.id, required this.customerId, required this.points, required this.tier});

  factory LoyaltyAccountModel.fromJson(Map<String, dynamic> json) => LoyaltyAccountModel(
        id: json['id'] as int,
        customerId: json['customer_id'] as int,
        points: json['points'] as int,
        tier: json['tier'] as String,
      );

  @override
  List<Object?> get props => [id, customerId, points, tier];
}
