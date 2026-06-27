import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/inventory_model.dart';

class InventoryService {
  InventoryService(this._dio);
  final Dio _dio;

  Future<List<InventoryItemModel>> list() async {
    final response = await _dio.get(ApiPaths.inventory);
    return (response.data as List<dynamic>).map((e) => InventoryItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<InventoryItemModel>> lowStock() async {
    final response = await _dio.get(ApiPaths.inventoryLowStock);
    return (response.data as List<dynamic>).map((e) => InventoryItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<InventoryItemModel> addBatch(int medicationId, Map<String, dynamic> payload) async {
    final response = await _dio.post(ApiPaths.inventoryAddBatch(medicationId), data: payload);
    return InventoryItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<InventoryItemModel> update(int itemId, Map<String, dynamic> payload) async {
    final response = await _dio.patch(ApiPaths.inventoryUpdate(itemId), data: payload);
    return InventoryItemModel.fromJson(response.data as Map<String, dynamic>);
  }
}
