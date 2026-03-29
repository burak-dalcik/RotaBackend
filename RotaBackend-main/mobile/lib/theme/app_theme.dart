import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Deep transit blue, bright warning yellow, light surfaces (HTML mockups + spec).
class AppTheme {
  static const Color deepTransitBlue = Color(0xFF001E40);
  static const Color brightWarningYellow = Color(0xFFFFE16D);
  static const Color surfaceLight = Color(0xFFF9F9F9);

  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: deepTransitBlue,
      brightness: Brightness.light,
      primary: deepTransitBlue,
      surface: surfaceLight,
    );
    final inter = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: base.copyWith(
        secondary: brightWarningYellow,
        onSecondary: const Color(0xFF221B00),
      ),
      scaffoldBackgroundColor: surfaceLight,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: deepTransitBlue,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: deepTransitBlue,
        ),
      ),
      textTheme: inter.copyWith(
        displaySmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          color: deepTransitBlue,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        titleSmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: deepTransitBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );
  }
}
