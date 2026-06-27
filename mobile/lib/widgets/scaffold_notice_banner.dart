import 'package:flutter/material.dart';
import 'safety_callout.dart';

class ScaffoldNoticeBanner extends StatelessWidget {
  const ScaffoldNoticeBanner({super.key, required this.feature});
  final String feature;

  @override
  Widget build(BuildContext context) {
    return SafetyCallout(
      severity: CalloutSeverity.warning,
      title: 'واجهة جاهزة، بانتظار ربط الـ Backend: $feature',
      message: 'البيانات المعروضة هنا توضيحية (mock) لشرح التصميم والتدفق فقط.',
    );
  }
}
