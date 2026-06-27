import 'package:flutter/material.dart';
import '../../widgets/scaffold_notice_banner.dart';
import '../../widgets/stat_card.dart';

class AiMonitoringScreen extends StatelessWidget {
  const AiMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ScaffoldNoticeBanner(feature: 'مقاييس استخدام AI (عدد المحادثات، نسبة التحويل، زمن الاستجابة)'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: const [
            StatCard(icon: Icons.chat_bubble_outline_rounded, label: 'محادثات هذا الأسبوع', value: '—'),
            StatCard(icon: Icons.shield_outlined, label: 'نسبة التحويل للصيدلاني', value: '—'),
            StatCard(icon: Icons.speed_outlined, label: 'متوسط زمن الاستجابة', value: '—'),
            StatCard(icon: Icons.insights_outlined, label: 'دقة استخراج الوصفات', value: '—'),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'ما هو متصل فعليًا اليوم: محرك السلامة الدوائي (التكرار/التعارض/الحساسية) قائم على قواعد محددة '
              'ومُختبر تلقائيًا في الـ Backend. ما يحتاج بناءً إضافيًا هو طبقة "تحليلات استخدام الذكاء الاصطناعي" '
              'لتتغذى منها هذه الشاشة ببيانات حقيقية.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}
