import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/cache_service.dart';
import '../models/medication_model.dart';
import '../services/medication_service.dart';

class MedicationRepository {
  MedicationRepository(this._service, this._cache);
  final MedicationService _service;
  final CacheService _cache;

  Future<ApiResult<List<MedicationSearchResultModel>>> search(String query) async {
    final cacheKey = 'medication_search_${query.toLowerCase()}';
    try {
      final results = await _service.search(query);
      await _cache.set(cacheKey, results.map((r) => r.toCacheJson()).toList(), ttl: const Duration(minutes: 10));
      return Success(results);
    } catch (e) {
      // Offline fallback: serve the last cached results for this exact query, if any.
      final cached = _cache.get<List<MedicationSearchResultModel>>(
        cacheKey,
        (json) => (json as List<dynamic>).map((e) => MedicationSearchResultModel.fromJson(e as Map<String, dynamic>)).toList(),
      );
      if (cached != null) return Success(cached);
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<MedicationModel>> getById(int id) async {
    try {
      return Success(await _service.getById(id));
    } catch (e) {
      return Error(mapDioError(e));
    }
  }
}

extension on MedicationSearchResultModel {
  Map<String, dynamic> toCacheJson() => {
        'medication': {
          'id': medication.id,
          'name_en': medication.nameEn,
          'name_ar': medication.nameAr,
          'dosage_form': medication.dosageForm,
          'strength': medication.strength,
          'manufacturer': medication.manufacturer,
          'requires_prescription': medication.requiresPrescription,
          'price': medication.price,
          'general_usage': medication.generalUsage,
          'general_warnings': medication.generalWarnings,
          'pregnancy_warning': medication.pregnancyWarning,
          'pediatric_warning': medication.pediatricWarning,
          'elderly_warning': medication.elderlyWarning,
          'active_ingredient': medication.activeIngredient == null
              ? null
              : {
                  'id': medication.activeIngredient!.id,
                  'name_en': medication.activeIngredient!.nameEn,
                  'name_ar': medication.activeIngredient!.nameAr,
                },
        },
        'in_stock': inStock,
        'quantity_available': quantityAvailable,
        'substitutes': substitutes
            .map((s) => {
                  'id': s.id,
                  'name_en': s.nameEn,
                  'name_ar': s.nameAr,
                  'requires_prescription': s.requiresPrescription,
                  'price': s.price,
                })
            .toList(),
      };
}
