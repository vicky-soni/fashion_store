
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFD4AF72);
  static const Color secondary = Color(0xFFE8C98E);

  static const Color background = Color(0xFF101010);
  static const Color surface = Color(0xFF1C1C1C);
  static const Color beige = Color(0xFF292929);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFBDBDBD);

  static const Color border = Color(0xFF383838);
  static const Color success = Color(0xFF69B578);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,

      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        onSurface: textPrimary,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
      ),

      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 15,
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: textSecondary),
        labelStyle: const TextStyle(color: textSecondary),
        prefixIconColor: textSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: primary,
            width: 1.5,
          ),
        ),
      ),

      bottomNavigationBarTheme:
          const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: beige,
        selectedColor: primary,
        labelStyle: const TextStyle(color: textPrimary),
        secondaryLabelStyle: const TextStyle(color: Colors.black),
        side: const BorderSide(color: border),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border),
        ),
      ),

      dividerColor: border,

      iconTheme: const IconThemeData(
        color: textPrimary,
      ),
    );
  }
}
