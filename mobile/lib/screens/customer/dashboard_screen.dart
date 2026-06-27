import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_paths.dart';
import '../../providers/auth_provider.dart';
import '../../providers/prescription_providers.dart';
import '../../providers/reminder_loyalty_providers.dart';
import '../../widgets/notification_bell_button.dart';
import '../../widgets/stat_card.dart';

class CustomerDashboardScreen extends ConsumerWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final prescriptionsAsync = ref.watch(myPrescriptionsProvider);
    final remindersAsync = ref.watch(remindersProvider);
    final loyaltyAsync = ref.watch(loyaltyAccountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('روشتة AI'), actions: const [NotificationBellButton(), SizedBox(width: 8)]),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myPrescriptionsProvider);
          ref.invalidate(remindersProvider);
          ref.invalidate(loyaltyAccountProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('مرحبًا، ${user?.fullName ?? ''} 👋', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('نظرة سريعة على حسابك في الصيدلية', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.4,
              children: [
                StatCard(
                  icon: Icons.description_outlined,
                  label: 'إجمالي وصفاتي',
                  value: prescriptionsAsync.maybeWhen(data: (d) => '${d.length}', orElse: () => '—'),
                  onTap: () => context.go(RoutePaths.customerPrescriptions),
                ),
                StatCard(
                  icon: Icons.alarm_outlined,
                  label: 'تذكيرات فعّالة',
                  value: remindersAsync.maybeWhen(data: (d) => '${d.length}', orElse: () => '—'),
                  color: Theme.of(context).colorScheme.secondary,
                  onTap: () => context.push(RoutePaths.customerReminders),
                ),
                StatCard(
                  icon: Icons.workspace_premium_outlined,
                  label: 'نقاط الولاء',
                  value: loyaltyAsync.maybeWhen(data: (d) => '${d.points}', orElse: () => '—'),
                  color: const Color(0xFF1F9D6A),
                  onTap: () => context.push(RoutePaths.customerLoyalty),
                ),
                StatCard(
                  icon: Icons.smart_toy_outlined,
                  label: 'المساعد الذكي',
                  value: 'اسأل الآن',
                  color: const Color(0xFF2563EB),
                  onTap: () => context.go(RoutePaths.customerChat),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('إجراءات سريعة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _QuickActionTile(
              icon: Icons.upload_file_rounded,
              title: 'رفع وصفة طبية جديدة',
              subtitle: 'صوّر وصفتك ودع الذكاء الاصطناعي يحللها',
              onTap: () => context.push(RoutePaths.customerPrescriptionUpload),
            ),
            const SizedBox(height: 10),
            _QuickActionTile(
              icon: Icons.search_rounded,
              title: 'البحث عن دواء',
              subtitle: 'تحقق من التوفر والبدائل المتاحة',
              onTap: () => context.go(RoutePaths.customerSearch),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
