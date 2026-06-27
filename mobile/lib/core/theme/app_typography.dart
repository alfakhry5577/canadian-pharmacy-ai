import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Display face: Noto Kufi Arabic (geometric, modern — used for headings).
/// Body face: Cairo (excellent Arabic + Latin legibility at small sizes).
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color color) {
    final base = GoogleFonts.cairoTextTheme().apply(bodyColor: color, displayColor: color);
    return base.copyWith(
      displayLarge: GoogleFonts.notoKufiArabic(fontSize: 32, fontWeight: FontWeight.w700, color: color),
      displayMedium: GoogleFonts.notoKufiArabic(fontSize: 26, fontWeight: FontWeight.w700, color: color),
      headlineMedium: GoogleFonts.notoKufiArabic(fontSize: 22, fontWeight: FontWeight.w700, color: color),
      headlineSmall: GoogleFonts.notoKufiArabic(fontSize: 18, fontWeight: FontWeight.w700, color: color),
      titleLarge: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: color),
      titleMedium: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, color: color),
      bodyLarge: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w400, color: color),
      bodyMedium: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w400, color: color),
      labelLarge: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: color),
    );
  }
}
