import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/medication_model.dart';
import '../../providers/medication_providers.dart';
import '../../providers/core_providers.dart';
import '../../providers/reminder_loyalty_providers.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_error_states.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/skeleton_loader.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تذكيرات إعادة الشراء'),
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => _showAddReminderSheet(context, ref)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(remindersProvider),
        child: remindersAsync.when(
          loading: () => const Padding(padding: EdgeInsets.all(16), child: SkeletonCardList(count: 3)),
          error: (e, _) => ErrorStateWidget(message: '$e', onRetry: () => ref.invalidate(remindersProvider)),
          data: (reminders) {
            if (reminders.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.alarm_outlined,
                title: 'لا توجد تذكيرات حاليًا',
                description: 'أضف تذكيرًا لإعادة شراء أدويتك المزمنة قبل نفادها.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final r = reminders[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.alarm_outlined),
                    title: Text('دواء #${r.medicationId}'),
                    subtitle: Text('موعد التذكير: ${Formatters.dateOnly(r.nextReminderDate)} · كل ${r.frequencyDays} يومًا'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      onPressed: () async {
                        await ref.read(customerRepositoryProvider).cancelReminder(r.id);
                        ref.invalidate(remindersProvider);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showAddReminderSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddReminderSheet(),
    );
  }
}

class _AddReminderSheet extends ConsumerStatefulWidget {
  const _AddReminderSheet();

  @override
  ConsumerState<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends ConsumerState<_AddReminderSheet> {
  MedicationModel? _selected;
  final _frequencyController = TextEditingController(text: '30');
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إضافة تذكير بإعادة الشراء', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          if (_selected != null)
            Card(
              child: ListTile(
                title: Text(_selected!.nameAr),
                trailing: TextButton(onPressed: () => setState(() => _selected = null), child: const Text('تغيير')),
              ),
            )
          else
            AppTextField(
              label: 'ابحث عن الدواء',
              onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
            ),
          if (_selected == null) ...[
            const SizedBox(height: 8),
            Consumer(builder: (context, ref, _) {
              final resultsAsync = ref.watch(medicationSearchResultsProvider);
              return resultsAsync.maybeWhen(
                data: (results) => Column(
                  children: results
                      .take(5)
                      .map((r) => ListTile(
                            dense: true,
                            title: Text(r.medication.nameAr),
                            onTap: () => setState(() => _selected = r.medication),
                          ))
                      .toList(),
                ),
                orElse: () => const SizedBox.shrink(),
              );
            }),
          ],
          const SizedBox(height: 12),
          AppTextField(label: 'التكرار (بالأيام)', controller: _frequencyController, keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'حفظ',
            isLoading: _isSubmitting,
            onPressed: _selected == null
                ? null
                : () async {
                    setState(() => _isSubmitting = true);
                    final result = await ref.read(customerRepositoryProvider).createReminder(
                          medicationId: _selected!.id,
                          frequencyDays: int.tryParse(_frequencyController.text) ?? 30,
                        );
                    if (!mounted) return;
                    setState(() => _isSubmitting = false);
                    result.when(
                      success: (_) {
                        ref.invalidate(remindersProvider);
                        Navigator.of(context).pop();
                      },
                      failure: (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
