import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFFFAFAFA);
  static const textBorder = Color(0xFFD4D4D8);
  static const textFill = Colors.white;
  static const textTitle = Color(0xFF18181B);
  static const hintText = Color(0xFF71717A);
  static const buttonFill = Color(0xFF18181B);
  static const buttonBorder = Color(0xFF18181B);
  static const appBarBackground = Colors.white;
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Padauk',
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: textTitle,
      primary: textTitle,
      secondary: const Color(0xFF52525B),
      primaryContainer: const Color(0xFFE4E4E7),
      onPrimaryContainer: textTitle,
      secondaryContainer: const Color(0xFFE4E4E7),
      onSecondaryContainer: textTitle,
      tertiaryContainer: const Color(0xFFF4F4F5),
      onTertiaryContainer: textTitle,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textTitle,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE4E4E7)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: textBorder),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Color(0xFFE4E4E7),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
  );
}
