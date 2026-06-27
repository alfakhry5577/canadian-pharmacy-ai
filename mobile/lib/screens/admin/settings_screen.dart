import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_locale_providers.dart';
import '../../widgets/scaffold_notice_banner.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('تفضيلات التطبيق', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                title: const Text('المظهر'),
                trailing: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined)),
                    ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined)),
                    ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_outlined)),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).setMode(s.first),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('اللغة'),
                trailing: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'ar', label: Text('العربية')),
                    ButtonSegment(value: 'en', label: Text('English')),
                  ],
                  selected: {locale.languageCode},
                  onSelectionChanged: (s) => ref.read(localeProvider.notifier).setLocale(Locale(s.first)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('إعدادات النظام', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const ScaffoldNoticeBanner(feature: 'GET/PATCH /api/admin/settings — حاليًا تُضبط من .env في الـ Backend'),
        const SizedBox(height: 12),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'تذكير أمان: مفتاح ANTHROPIC_API_KEY ومفاتيح Firebase تُضبط فقط من متغيرات البيئة على الخادم، '
              'ولا يجب أبدًا تضمينها داخل تطبيق الموبايل.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
