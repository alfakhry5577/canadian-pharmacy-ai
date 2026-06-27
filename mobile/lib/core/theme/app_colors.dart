import 'package:flutter/material.dart';

/// Brand color tokens, kept in one place so light/dark themes and ad-hoc
/// widgets (badges, charts) stay visually consistent with the web app's
/// "clinical calm" palette.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF0B5C45); // deep sage/teal
  static const Color primaryLight = Color(0xFF2F9E76);
  static const Color secondary = Color(0xFFD97A3D); // warm clay/amber

  // Light theme surfaces
  static const Color backgroundLight = Color(0xFFEAF4EE);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF1C2421);

  // Dark theme surfaces
  static const Color backgroundDark = Color(0xFF10231D);
  static const Color surfaceDark = Color(0xFF16302A);
  static const Color onSurfaceDark = Color(0xFFE7F3EE);

  // Semantic
  static const Color success = Color(0xFF1F9D6A);
  static const Color warning = Color(0xFFD9882F);
  static const Color critical = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  static const Color muted = Color(0xFF8C9A95);
}
