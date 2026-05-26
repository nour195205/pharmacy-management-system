import 'package:flutter/material.dart';

class AppTheme {
  // Theme Color Palette
  static const Color primaryTeal = Color(0xFF0D9488); // Modern Vibrant Teal
  static const Color secondarySlate = Color(0xFF64748B); // Slate Gray
  static const Color accentIndigo = Color(0xFF4F46E5); // Indigo Accent

  // Dark Mode Colors
  static const Color darkBg = Color(0xFF0F172A); // Very dark slate (900)
  static const Color darkCard = Color(0xFF1E293B); // Dark slate card (800)
  static const Color darkText = Color(0xFFF8FAFC); // Slate text (50)
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate text (400)

  // Light Mode Colors
  static const Color lightBg = Color(0xFFF8FAFC); // Very light slate (50)
  static const Color lightCard = Color(0xFFFFFFFF); // White card
  static const Color lightText = Color(0xFF0F172A); // Slate text (900)
  static const Color lightTextSecondary = Color(0xFF475569); // Slate text (600)

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: lightBg,
      cardColor: lightCard,
      fontFamily: 'Segoe UI', // Standard Windows font
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBg,
        elevation: 0,
        iconTheme: IconThemeData(color: lightText),
        titleTextStyle: TextStyle(
          color: lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Segoe UI',
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: lightText, fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: lightText, fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: lightText, fontSize: 14),
        bodyMedium: TextStyle(color: lightTextSecondary, fontSize: 12),
      ),
      cardTheme: CardTheme(
        color: lightCard,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: lightCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF1F5F9), // Slate 100
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryTeal, width: 1.5),
        ),
        labelStyle: const TextStyle(color: lightTextSecondary, fontSize: 14),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCard,
      fontFamily: 'Segoe UI',
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        iconTheme: IconThemeData(color: darkText),
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Segoe UI',
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: darkText, fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: darkText, fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: darkText, fontSize: 14),
        bodyMedium: TextStyle(color: darkTextSecondary, fontSize: 12),
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: darkCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1E293B), // Slate 800
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryTeal, width: 1.5),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary, fontSize: 14),
      ),
    );
  }
}
