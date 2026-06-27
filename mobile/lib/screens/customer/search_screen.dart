import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/medication_model.dart';
import '../../providers/medication_providers.dart';
import '../../widgets/empty_error_states.dart';
import '../../widgets/skeleton_loader.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(medicationSearchResultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('البحث عن دواء')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'ابحث باسم الدواء أو المادة الفعالة...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: query.trim().length < 2
                  ? const EmptyStateWidget(icon: Icons.search_rounded, title: 'ابدأ بكتابة اسم الدواء', description: 'مثال: بنادول، أو Ibuprofen')
                  : resultsAsync.when(
                      loading: () => const SkeletonCardList(count: 4, cardHeight: 110),
                      error: (e, _) => ErrorStateWidget(message: '$e', onRetry: () => ref.invalidate(medicationSearchResultsProvider)),
                      data: (results) {
                        if (results.isEmpty) {
                          return const EmptyStateWidget(icon: Icons.search_off_rounded, title: 'لم يتم العثور على نتائج مطابقة');
                        }
                        return ListView.separated(
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) => _MedicationResultCard(result: results[i]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationResultCard extends StatelessWidget {
  const _MedicationResultCard({required this.result});
  final MedicationSearchResultModel result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final med = result.medication;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(med.nameAr, style: theme.textTheme.titleMedium),
                      Text(med.nameEn, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Text(Formatters.currency(med.price), style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (med.requiresPrescription)
                  _Tag(icon: Icons.assignment_outlined, label: 'يتطلب وصفة', color: theme.colorScheme.secondary),
                result.inStock
                    ? _Tag(icon: Icons.check_circle_outline, label: 'متوفر (${result.quantityAvailable})', color: const Color(0xFF1F9D6A))
                    : _Tag(icon: Icons.cancel_outlined, label: 'غير متوفر حاليًا', color: const Color(0xFFDC2626)),
              ],
            ),
            if (med.generalUsage != null) ...[
              const SizedBox(height: 10),
              Text(med.generalUsage!, style: theme.textTheme.bodySmall),
            ],
            if (!result.inStock && result.substitutes.isNotEmpty) ...[
              const Divider(height: 24),
              Text('بدائل متوفرة بنفس المادة الفعالة:', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result.substitutes
                    .map((s) => _Tag(icon: Icons.swap_horiz_rounded, label: '${s.nameAr} — ${Formatters.currency(s.price)}', color: theme.colorScheme.primary))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
