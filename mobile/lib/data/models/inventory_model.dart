import 'package:equatable/equatable.dart';

class InventoryItemModel extends Equatable {
  final int id;
  final int medicationId;
  final int quantity;
  final int reorderThreshold;
  final String? batchNo;
  final String? expiryDate;
  final bool isLowStock;

  const InventoryItemModel({
    required this.id,
    required this.medicationId,
    required this.quantity,
    required this.reorderThreshold,
    required this.batchNo,
    required this.expiryDate,
    required this.isLowStock,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) => InventoryItemModel(
        id: json['id'] as int,
        medicationId: json['medication_id'] as int,
        quantity: json['quantity'] as int,
        reorderThreshold: json['reorder_threshold'] as int,
        batchNo: json['batch_no'] as String?,
        expiryDate: json['expiry_date'] as String?,
        isLowStock: json['is_low_stock'] as bool? ?? false,
      );

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final expiry = DateTime.tryParse(expiryDate!);
    if (expiry == null) return false;
    return expiry.difference(DateTime.now()).inDays <= 60;
  }

  @override
  List<Object?> get props => [id, medicationId, quantity, reorderThreshold, batchNo, expiryDate, isLowStock];
}
