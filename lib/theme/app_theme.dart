import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ألوان وهوية بصرية موحدة لتطبيق "بوابة العقارات"
class AppColors {
  static const primary = Color(0xFF0E6655);
  static const primaryLight = Color(0xFF16A085);
  static const secondary = Color(0xFFD4A017);
  static const bg = Color(0xFFF7F8FA);
  static const card = Colors.white;
  static const textDark = Color(0xFF1C2B33);
  static const textGrey = Color(0xFF7A8A94);
  static const saleColor = Color(0xFF0E6655);
  static const rentColor = Color(0xFF2E6FDB);
  static const danger = Color(0xFFE74C3C);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: GoogleFonts.cairo().fontFamily,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      textTheme: GoogleFonts.cairoTextTheme().apply(bodyColor: AppColors.textDark),
    );
  }
}
