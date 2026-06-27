import 'package:equatable/equatable.dart';

class TopMedicationStatModel extends Equatable {
  final int medicationId;
  final String nameAr;
  final int totalQuantitySold;
  final String totalRevenue;

  const TopMedicationStatModel({
    required this.medicationId,
    required this.nameAr,
    required this.totalQuantitySold,
    required this.totalRevenue,
  });

  factory TopMedicationStatModel.fromJson(Map<String, dynamic> json) => TopMedicationStatModel(
        medicationId: json['medication_id'] as int,
        nameAr: json['name_ar'] as String,
        totalQuantitySold: json['total_quantity_sold'] as int,
        totalRevenue: json['total_revenue'].toString(),
      );

  @override
  List<Object?> get props => [medicationId, nameAr, totalQuantitySold, totalRevenue];
}

class SalesSummaryModel extends Equatable {
  final String periodLabel;
  final int totalOrders;
  final String totalRevenue;
  final List<TopMedicationStatModel> topMedications;
  final int lowStockCount;
  final int expiringSoonCount;

  const SalesSummaryModel({
    required this.periodLabel,
    required this.totalOrders,
    required this.totalRevenue,
    required this.topMedications,
    required this.lowStockCount,
    required this.expiringSoonCount,
  });

  factory SalesSummaryModel.fromJson(Map<String, dynamic> json) => SalesSummaryModel(
        periodLabel: json['period_label'] as String,
        totalOrders: json['total_orders'] as int,
        totalRevenue: json['total_revenue'].toString(),
        topMedications: (json['top_medications'] as List<dynamic>? ?? [])
            .map((e) => TopMedicationStatModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        lowStockCount: json['low_stock_count'] as int,
        expiringSoonCount: json['expiring_soon_count'] as int,
      );

  @override
  List<Object?> get props => [periodLabel, totalOrders, totalRevenue, topMedications, lowStockCount, expiringSoonCount];
}
