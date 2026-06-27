import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/inventory_model.dart';
import '../../providers/inventory_providers.dart';
import '../../widgets/empty_error_states.dart';
import '../../widgets/skeleton_loader.dart';

class PharmacistInventoryScreen extends ConsumerWidget {
  const PharmacistInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المخزون')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(inventoryListProvider),
        child: inventoryAsync.when(
          loading: () => const Padding(padding: EdgeInsets.all(16), child: SkeletonCardList(count: 5, cardHeight: 70)),
          error: (e, _) => ErrorStateWidget(message: '$e', onRetry: () => ref.invalidate(inventoryListProvider)),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyStateWidget(icon: Icons.inventory_2_outlined, title: 'لا توجد دفعات مخزون مسجّلة بعد');
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _InventoryTile(item: items[i]),
            );
          },
        ),
      ),
    );
  }
}

class _InventoryTile extends StatelessWidget {
  const _InventoryTile({required this.item});
  final InventoryItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: item.isLowStock ? theme.colorScheme.error.withOpacity(0.05) : null,
      child: ListTile(
        title: Text('دواء #${item.medicationId}'),
        subtitle: Text('الكمية: ${item.quantity} · تشغيلة ${item.batchNo ?? "—"} · ينتهي ${Formatters.dateOnly(item.expiryDate)}'),
        trailing: Wrap(
          spacing: 4,
          children: [
            if (item.isLowStock) const Chip(label: Text('منخفض', style: TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact, backgroundColor: Color(0x1ADC2626)),
            if (item.isExpiringSoon) const Chip(label: Text('قرب الانتهاء', style: TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact, backgroundColor: Color(0x1AD97706)),
          ],
        ),
      ),
    );
  }
}
