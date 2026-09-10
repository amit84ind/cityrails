import 'package:flutter/material.dart';

class TirangaTheme {
  // Tiranga Colors
  static const Color saffron = Color(0xFFFF9933);
  static const Color saffronDark = Color(0xFFE65100);
  static const Color white = Color(0xFFFFFFFF);
  static const Color green = Color(0xFF138808);
  static const Color greenDark = Color(0xFF006400);
  static const Color navyBlue = Color(0xFF000080);
  
  // App UI Palette
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color surfaceDark = Color(0xFF2A2A2A);
  
  // Status Colors
  static const Color fastTrainRed = Color(0xFFE53935);
  static const Color slowTrainGreen = Color(0xFF4CAF50);
  static const Color acTrainPurple = Color(0xFF9C27B0);
  static const Color ladiesTrainPink = Color(0xFFE91E63);
  static const Color delayOrange = Color(0xFFFF9800);

  static ThemeData get darkTirangaTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: saffron,
      colorScheme: const ColorScheme.dark(
        primary: saffron,
        secondary: green,
        surface: cardDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: saffron,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
