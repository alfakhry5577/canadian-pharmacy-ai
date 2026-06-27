import 'package:flutter/material.dart';

enum CalloutSeverity { info, warning, critical }

class SafetyCallout extends StatelessWidget {
  const SafetyCallout({super.key, required this.message, this.title, this.severity = CalloutSeverity.info});

  final String message;
  final String? title;
  final CalloutSeverity severity;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (severity) {
      CalloutSeverity.info => (const Color(0xFFEFF6FF), const Color(0xFF1D4ED8), Icons.info_outline_rounded),
      CalloutSeverity.warning => (const Color(0xFFFFF7ED), const Color(0xFFB45309), Icons.warning_amber_rounded),
      CalloutSeverity.critical => (const Color(0xFFFEF2F2), const Color(0xFFB91C1C), Icons.shield_outlined),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: fg.withValues(alpha: 0.25))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(title!, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                Text(message, style: TextStyle(color: fg, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

CalloutSeverity calloutSeverityFromString(String value) => switch (value) {
      'critical' => CalloutSeverity.critical,
      'warning' => CalloutSeverity.warning,
      _ => CalloutSeverity.info,
    };
