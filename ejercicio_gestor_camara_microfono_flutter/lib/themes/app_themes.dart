import 'package:flutter/material.dart';

enum AppThemeType {
  guindaIPN,
  azulESCOM,
}

class AppThemes {
  // Colores Tema Guinda IPN
  static const Color guindaPrimary = Color(0xFF7E1538);
  static const Color guindaPrimaryVariant = Color(0xFF5E1028);
  static const Color guindaSecondary = Color(0xFFD4AF37);
  
  // Colores Tema Azul ESCOM
  static const Color azulPrimary = Color(0xFF1565C0);
  static const Color azulPrimaryVariant = Color(0xFF0D47A1);
  static const Color azulSecondary = Color(0xFFFFC107);
  
  // Tema Guinda IPN - Modo Claro
  static final ThemeData guindaLightTheme = ThemeData(
    primarySwatch: MaterialColor(
      guindaPrimary.value,
      <int, Color>{
        50: guindaPrimary.withOpacity(0.1),
        100: guindaPrimary.withOpacity(0.2),
        200: guindaPrimary.withOpacity(0.3),
        300: guindaPrimary.withOpacity(0.4),
        400: guindaPrimary.withOpacity(0.5),
        500: guindaPrimary,
        600: guindaPrimary.withOpacity(0.7),
        700: guindaPrimary.withOpacity(0.8),
        800: guindaPrimary.withOpacity(0.9),
        900: guindaPrimaryVariant,
      },
    ),
    colorScheme: const ColorScheme.light(
      primary: guindaPrimary,
      primaryContainer: guindaPrimaryVariant,
      secondary: guindaSecondary,
      surface: Colors.white,
      background: Color(0xFFF5F5F5),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black87,
      onBackground: Colors.black87,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: guindaPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: guindaPrimary,
        foregroundColor: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: guindaSecondary,
      foregroundColor: Colors.black,
    ),
  );
  
  // Tema Guinda IPN - Modo Oscuro
  static final ThemeData guindaDarkTheme = ThemeData(
    primarySwatch: MaterialColor(
      guindaPrimary.value,
      <int, Color>{
        50: guindaPrimary.withOpacity(0.1),
        100: guindaPrimary.withOpacity(0.2),
        200: guindaPrimary.withOpacity(0.3),
        300: guindaPrimary.withOpacity(0.4),
        400: guindaPrimary.withOpacity(0.5),
        500: guindaPrimary,
        600: guindaPrimary.withOpacity(0.7),
        700: guindaPrimary.withOpacity(0.8),
        800: guindaPrimary.withOpacity(0.9),
        900: guindaPrimaryVariant,
      },
    ),
    colorScheme: const ColorScheme.dark(
      primary: guindaPrimary,
      primaryContainer: guindaPrimaryVariant,
      secondary: guindaSecondary,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: guindaPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: guindaPrimary,
        foregroundColor: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: guindaSecondary,
      foregroundColor: Colors.black,
    ),
  );
  
  // Tema Azul ESCOM - Modo Claro
  static final ThemeData azulLightTheme = ThemeData(
    primarySwatch: MaterialColor(
      azulPrimary.value,
      <int, Color>{
        50: azulPrimary.withOpacity(0.1),
        100: azulPrimary.withOpacity(0.2),
        200: azulPrimary.withOpacity(0.3),
        300: azulPrimary.withOpacity(0.4),
        400: azulPrimary.withOpacity(0.5),
        500: azulPrimary,
        600: azulPrimary.withOpacity(0.7),
        700: azulPrimary.withOpacity(0.8),
        800: azulPrimary.withOpacity(0.9),
        900: azulPrimaryVariant,
      },
    ),
    colorScheme: const ColorScheme.light(
      primary: azulPrimary,
      primaryContainer: azulPrimaryVariant,
      secondary: azulSecondary,
      surface: Colors.white,
      background: Color(0xFFF5F5F5),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black87,
      onBackground: Colors.black87,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: azulPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: azulPrimary,
        foregroundColor: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: azulSecondary,
      foregroundColor: Colors.black,
    ),
  );
  
  // Tema Azul ESCOM - Modo Oscuro
  static final ThemeData azulDarkTheme = ThemeData(
    primarySwatch: MaterialColor(
      azulPrimary.value,
      <int, Color>{
        50: azulPrimary.withOpacity(0.1),
        100: azulPrimary.withOpacity(0.2),
        200: azulPrimary.withOpacity(0.3),
        300: azulPrimary.withOpacity(0.4),
        400: azulPrimary.withOpacity(0.5),
        500: azulPrimary,
        600: azulPrimary.withOpacity(0.7),
        700: azulPrimary.withOpacity(0.8),
        800: azulPrimary.withOpacity(0.9),
        900: azulPrimaryVariant,
      },
    ),
    colorScheme: const ColorScheme.dark(
      primary: azulPrimary,
      primaryContainer: azulPrimaryVariant,
      secondary: azulSecondary,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: azulPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: azulPrimary,
        foregroundColor: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: azulSecondary,
      foregroundColor: Colors.black,
    ),
  );
  
  static ThemeData getTheme(AppThemeType themeType, bool isDarkMode) {
    switch (themeType) {
      case AppThemeType.guindaIPN:
        return isDarkMode ? guindaDarkTheme : guindaLightTheme;
      case AppThemeType.azulESCOM:
        return isDarkMode ? azulDarkTheme : azulLightTheme;
    }
  }
}