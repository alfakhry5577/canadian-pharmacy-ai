import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String currency(String priceString) {
    final value = double.tryParse(priceString) ?? 0;
    final formatted = NumberFormat.decimalPattern('ar').format(value);
    return '$formatted د.ل';
  }

  static String dateTime(String? iso) {
    if (iso == null) return '-';
    final date = DateTime.tryParse(iso);
    if (date == null) return iso;
    return DateFormat('d MMMM y، h:mm a', 'ar').format(date.toLocal());
  }

  static String dateOnly(String? iso) {
    if (iso == null) return '-';
    final date = DateTime.tryParse(iso);
    if (date == null) return iso;
    return DateFormat('d MMMM y', 'ar').format(date.toLocal());
  }

  static int confidencePercent(double score) => (score.clamp(0, 1) * 100).round();

  static String initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join();
  }
}
