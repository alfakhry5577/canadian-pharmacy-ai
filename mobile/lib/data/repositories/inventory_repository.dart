import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../models/inventory_model.dart';
import '../services/inventory_service.dart';

class InventoryRepository {
  InventoryRepository(this._service);
  final InventoryService _service;

  Future<ApiResult<List<InventoryItemModel>>> list() async {
    try {
      return Success(await _service.list());
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<List<InventoryItemModel>>> lowStock() async {
    try {
      return Success(await _service.lowStock());
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<InventoryItemModel>> addBatch(int medicationId, Map<String, dynamic> payload) async {
    try {
      return Success(await _service.addBatch(medicationId, payload));
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<InventoryItemModel>> update(int itemId, Map<String, dynamic> payload) async {
    try {
      return Success(await _service.update(itemId, payload));
    } catch (e) {
      return Error(mapDioError(e));
    }
  }
}
