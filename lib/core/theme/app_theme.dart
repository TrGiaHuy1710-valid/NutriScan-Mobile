import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color vibrantPrimary = Color(0xFF526646);          // Deep Sage / Forest Green
  static const Color vibrantSecondary = Color(0xFF3E4A36);        // Sage Dark Head
  static const Color vibrantLightHighlight = Color(0xFFE8F3DA);   // Light bright Sage / Lime-Sage
  static const Color vibrantBorderLight = Color(0xFFD2E0BD);      // Light sage border
  static const Color vibrantBorderMedium = Color(0xFFE2E3D8);     // Soft light border
  static const Color vibrantBackground = Color(0xFFFDFCF5);       // Warm Creamy background
  static const Color vibrantVolt = Color(0xFFC2EF00);             // Bright highlighter volt green

  // Status / Accent details
  static const Color vibrantAlertCoral = Color(0xFFE07A5F);       // Soft Coral for alerts
  static const Color vibrantSunburst = Color(0xFFF4A261);          // Yellow-Orange
  static const Color vibrantTextDark = Color(0xFF1B1C18);         // Contrast dark text
  static const Color vibrantTextMedium = Color(0xFF44483D);       // Muted text
  static const Color vibrantTextLight = Color(0xFF5C6052);        // Soft subtitles

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: vibrantBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: vibrantPrimary,
        onPrimary: Colors.white,
        secondary: vibrantSecondary,
        onSecondary: Colors.white,
        error: vibrantAlertCoral,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: vibrantTextDark,
        onSurfaceVariant: vibrantTextLight,
        outline: vibrantBorderMedium,
        outlineVariant: vibrantBorderLight,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: vibrantBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: vibrantTextDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: vibrantTextDark),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: vibrantBorderMedium, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: vibrantBorderMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: vibrantBorderMedium),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: vibrantPrimary, width: 2),
        ),
      ),
    );
  }
}
