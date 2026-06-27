import 'package:flutter/material.dart';
import '../../widgets/scaffold_notice_banner.dart';

const _mockUsers = [
  ('مدير النظام', 'admin@roshetta.ai', 'مدير النظام', true),
  ('د. سارة الصيدلانية', 'pharmacist@roshetta.ai', 'صيدلاني', true),
  ('أحمد الزبون', 'customer@roshetta.ai', 'زبون', true),
  ('ليلى محمود', 'layla@example.com', 'زبون', false),
];

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ScaffoldNoticeBanner(feature: 'GET/PATCH /api/admin/users (قائمة وتعديل المستخدمين)'),
        const SizedBox(height: 16),
        ..._mockUsers.map((u) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(u.$1),
                subtitle: Text(u.$2),
                trailing: Chip(
                  label: Text(u.$3, style: const TextStyle(fontSize: 11)),
                  backgroundColor: u.$4 ? const Color(0x1A1F9D6A) : const Color(0x1A8C9A95),
                ),
              ),
            )),
      ],
    );
  }
}
