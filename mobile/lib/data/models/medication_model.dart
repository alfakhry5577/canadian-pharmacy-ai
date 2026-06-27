import 'package:equatable/equatable.dart';

class ActiveIngredientModel extends Equatable {
  final int id;
  final String nameEn;
  final String nameAr;

  const ActiveIngredientModel({required this.id, required this.nameEn, required this.nameAr});

  factory ActiveIngredientModel.fromJson(Map<String, dynamic> json) => ActiveIngredientModel(
        id: json['id'] as int,
        nameEn: json['name_en'] as String,
        nameAr: json['name_ar'] as String,
      );

  @override
  List<Object?> get props => [id, nameEn, nameAr];
}

class MedicationModel extends Equatable {
  final int id;
  final String nameEn;
  final String nameAr;
  final String? dosageForm;
  final String? strength;
  final String? manufacturer;
  final bool requiresPrescription;
  final String price; // kept as string to match backend decimal serialization
  final String? generalUsage;
  final String? generalWarnings;
  final String? pregnancyWarning;
  final String? pediatricWarning;
  final String? elderlyWarning;
  final ActiveIngredientModel? activeIngredient;

  const MedicationModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.dosageForm,
    this.strength,
    this.manufacturer,
    required this.requiresPrescription,
    required this.price,
    this.generalUsage,
    this.generalWarnings,
    this.pregnancyWarning,
    this.pediatricWarning,
    this.elderlyWarning,
    this.activeIngredient,
  });

  double get priceAsDouble => double.tryParse(price) ?? 0;

  factory MedicationModel.fromJson(Map<String, dynamic> json) => MedicationModel(
        id: json['id'] as int,
        nameEn: json['name_en'] as String,
        nameAr: json['name_ar'] as String,
        dosageForm: json['dosage_form'] as String?,
        strength: json['strength'] as String?,
        manufacturer: json['manufacturer'] as String?,
        requiresPrescription: json['requires_prescription'] as bool? ?? true,
        price: json['price'].toString(),
        generalUsage: json['general_usage'] as String?,
        generalWarnings: json['general_warnings'] as String?,
        pregnancyWarning: json['pregnancy_warning'] as String?,
        pediatricWarning: json['pediatric_warning'] as String?,
        elderlyWarning: json['elderly_warning'] as String?,
        activeIngredient: json['active_ingredient'] != null
            ? ActiveIngredientModel.fromJson(json['active_ingredient'] as Map<String, dynamic>)
            : null,
      );

  @override
  List<Object?> get props => [id, nameEn, nameAr, price, requiresPrescription];
}

class MedicationSearchResultModel extends Equatable {
  final MedicationModel medication;
  final bool inStock;
  final int quantityAvailable;
  final List<MedicationModel> substitutes;

  const MedicationSearchResultModel({
    required this.medication,
    required this.inStock,
    required this.quantityAvailable,
    required this.substitutes,
  });

  factory MedicationSearchResultModel.fromJson(Map<String, dynamic> json) => MedicationSearchResultModel(
        medication: MedicationModel.fromJson(json['medication'] as Map<String, dynamic>),
        inStock: json['in_stock'] as bool,
        quantityAvailable: json['quantity_available'] as int,
        substitutes: (json['substitutes'] as List<dynamic>? ?? [])
            .map((e) => MedicationModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [medication, inStock, quantityAvailable, substitutes];
}
