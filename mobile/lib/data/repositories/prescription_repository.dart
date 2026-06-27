import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/cache_service.dart';
import '../models/prescription_model.dart';
import '../services/prescription_service.dart';

class PrescriptionRepository {
  PrescriptionRepository(this._service, this._cache);
  final PrescriptionService _service;
  final CacheService _cache;

  static const _mineCacheKey = 'prescriptions_mine';

  Future<ApiResult<PrescriptionAnalysisResultModel>> upload(String filePath) async {
    try {
      final result = await _service.upload(filePath);
      await _cache.invalidate(_mineCacheKey); // the list changed — force a fresh fetch next time
      return Success(result);
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<List<PrescriptionModel>>> mine() async {
    try {
      final list = await _service.mine();
      // Cache only lightweight identifiers; full detail is re-fetched per-screen when online.
      await _cache.set(_mineCacheKey, list.map((p) => p.id).toList(), ttl: const Duration(minutes: 30));
      return Success(list);
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<List<PrescriptionModel>>> queue() async {
    try {
      return Success(await _service.queue());
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<PrescriptionModel>> getById(int id) async {
    try {
      return Success(await _service.getById(id));
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<PrescriptionModel>> updateItem(int itemId, Map<String, dynamic> payload) async {
    try {
      return Success(await _service.updateItem(itemId, payload));
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<PrescriptionModel>> review(int id, {required String status, String? notes}) async {
    try {
      return Success(await _service.review(id, status: status, notes: notes));
    } catch (e) {
      return Error(mapDioError(e));
    }
  }
}
