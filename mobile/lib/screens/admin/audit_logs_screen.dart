import 'package:flutter/material.dart';
import '../../widgets/scaffold_notice_banner.dart';

const _mockLogs = [
  ('pharmacist@roshetta.ai', 'اعتماد وصفة #102', '2026-06-20 14:05'),
  ('admin@roshetta.ai', 'تعديل حد إعادة الطلب لدواء #14', '2026-06-20 11:22'),
  ('pharmacist@roshetta.ai', 'رفض وصفة #99 — صورة غير واضحة', '2026-06-19 19:47'),
];

class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ScaffoldNoticeBanner(feature: 'جدول audit_logs + middleware لتسجيل كل إجراء حساس تلقائيًا'),
        const SizedBox(height: 16),
        ..._mockLogs.map((log) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.history_outlined),
                title: Text(log.$2),
                subtitle: Text(log.$1),
                trailing: Text(log.$3, style: Theme.of(context).textTheme.bodySmall),
              ),
            )),
      ],
    );
  }
}
