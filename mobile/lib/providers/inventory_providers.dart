import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/inventory_model.dart';
import 'core_providers.dart';

final inventoryListProvider = FutureProvider.autoDispose<List<InventoryItemModel>>((ref) async {
  final result = await ref.watch(inventoryRepositoryProvider).list();
  return result.when(success: (data) => data, failure: (f) => throw f);
});

final lowStockInventoryProvider = FutureProvider.autoDispose<List<InventoryItemModel>>((ref) async {
  final result = await ref.watch(inventoryRepositoryProvider).lowStock();
  return result.when(success: (data) => data, failure: (f) => throw f);
});
