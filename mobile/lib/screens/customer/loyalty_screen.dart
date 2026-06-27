import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reminder_loyalty_providers.dart';
import '../../widgets/empty_error_states.dart';
import '../../widgets/skeleton_loader.dart';

const Map<String, String> _tierLabelsAr = {'bronze': 'البرونزية', 'silver': 'الفضية', 'gold': 'الذهبية'};
const Map<String, int> _tierThresholds = {'bronze': 500, 'silver': 2000, 'gold': 2000};

class LoyaltyScreen extends ConsumerWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loyaltyAsync = ref.watch(loyaltyAccountProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('نقاط الولاء')),
      body: loyaltyAsync.when(
        loading: () => const Padding(padding: EdgeInsets.all(16), child: SkeletonBox(height: 220, radius: 20)),
        error: (e, _) => ErrorStateWidget(message: '$e', onRetry: () => ref.invalidate(loyaltyAccountProvider)),
        data: (account) {
          final threshold = _tierThresholds[account.tier] ?? 500;
          final progress = account.tier == 'gold' ? 1.0 : (account.points / threshold).clamp(0, 1).toDouble();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('نقاط الولاء', style: TextStyle(color: Colors.white70)),
                            Text('${account.points}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 40),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الفئة: ${_tierLabelsAr[account.tier] ?? account.tier}', style: theme.textTheme.titleMedium),
                    if (account.tier != 'gold') Text('حتى الفئة التالية: $threshold', style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: progress, minHeight: 8),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.card_giftcard_outlined, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تُمنح النقاط تلقائيًا مع كل عملية شراء، ويمكن استبدالها بخصومات لاحقًا.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
