import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../providers/inventory_providers.dart';
import '../../widgets/empty_error_states.dart';
import '../../widgets/skeleton_loader.dart';

class AdminInventoryScreen extends ConsumerWidget {
  const AdminInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryListProvider);

    return RefreshIndicator(
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
            itemBuilder: (context, i) {
              final item = items[i];
              return Card(
                color: item.isLowStock ? Theme.of(context).colorScheme.error.withValues(alpha: 0.05) : null,
                child: ListTile(
                  title: Text('دواء #${item.medicationId}'),
                  subtitle: Text('الكمية: ${item.quantity} · ينتهي ${Formatters.dateOnly(item.expiryDate)}'),
                  trailing: item.isLowStock
                      ? const Chip(label: Text('منخفض', style: TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact)
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
