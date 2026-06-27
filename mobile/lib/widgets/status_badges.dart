import 'package:flutter/material.dart';
import '../data/models/prescription_model.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final PrescriptionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      PrescriptionStatus.pending => ('قيد المعالجة', const Color(0xFFD97706)),
      PrescriptionStatus.analyzed => ('بانتظار المراجعة', const Color(0xFFD97706)),
      PrescriptionStatus.reviewed => ('تمت المراجعة', const Color(0xFF1F9D6A)),
      PrescriptionStatus.dispensed => ('تم الصرف', const Color(0xFF1F9D6A)),
      PrescriptionStatus.rejected => ('مرفوضة', const Color(0xFFDC2626)),
    };
    return _Chip(label: label, color: color);
  }
}

class SeverityBadge extends StatelessWidget {
  const SeverityBadge({super.key, required this.severity});
  final String severity; // info | warning | critical

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (severity) {
      'critical' => ('حرج', const Color(0xFFDC2626)),
      'warning' => ('تحذير', const Color(0xFFD97706)),
      _ => ('معلومة', const Color(0xFF2563EB)),
    };
    return _Chip(label: label, color: color);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }
}
