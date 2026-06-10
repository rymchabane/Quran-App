import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color primaryGreen = Color(0xFF00C853);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color deepGreen = Color(0xFF0A1F0A);
  static const Color surfaceBlack = Color(0xFF0D0D0D);
  static const Color cardBlack = Color(0xFF161616);
  static const Color cardGrey = Color(0xFF1E1E1E);
  static const Color borderGrey = Color(0xFF2A2A2A);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF616161);
  static const Color accentGreen = Color(0xFF69F0AE);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surfaceBlack,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: accentGreen,
        surface: cardBlack,
        onPrimary: Colors.black,
        onSurface: textWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceBlack,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBlack,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderGrey, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textGrey),
        hintStyle: const TextStyle(color: textMuted),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBlack,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: borderGrey,
        thickness: 1,
      ),
    );
  }
}