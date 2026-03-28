// import 'package:flutter/material.dart';

// class AppTheme {
//   static ThemeData get lightTheme {
//     return ThemeData(
//       brightness: Brightness.light,
//       primaryColor: Colors.deepPurple,

//       colorScheme: ColorScheme.fromSeed(
//         seedColor: Colors.deepPurple,
//         brightness: Brightness.light,
//       ),
//       scaffoldBackgroundColor: Colors.white,
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       useMaterial3: true,
//     );
//   }

//   static ThemeData get darkTheme {
//     return ThemeData(
//       brightness: Brightness.dark,
//       primaryColor: Colors.deepPurpleAccent,
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: Colors.deepPurpleAccent,
//         brightness: Brightness.dark,
//       ),
//       scaffoldBackgroundColor: const Color(0xFF121212),
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Color(0xFF1E1E1E),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       useMaterial3: true,
//     );
//   }
// }
import 'package:flutter/material.dart';

class AppTheme {
  // -------------------
  // Colors
  // -------------------
  static const Color background = Color.fromARGB(255, 255, 255, 255);
  static const Color textBorder = Color(0xFF9C6644);
  static const Color textFill = Color(0xFFFFFFFF);
  static const Color textTitle = Color(0xFF1E1E1E);
  static const Color hintText = Color(0xFFB3B3B3);
  static const Color buttonFill = Color(0xFFC49A6C);
  static const Color buttonBorder = Color(0xFF9C6644);
  static const Color appBarBackground = Color(0xFFC49A6C);

  // -------------------
  // Text styles (Material 3 slots)
  // -------------------
  static TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: textTitle,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: textTitle,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textTitle,
    ),
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: textTitle,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textTitle,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: textTitle,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: textTitle,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: textTitle,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textTitle,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: textTitle),
    bodyMedium: TextStyle(fontSize: 14, color: textTitle),
    bodySmall: TextStyle(fontSize: 12, color: textTitle),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: textFill,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: textFill,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: textFill,
    ),
  );

  // -------------------
  // Light Theme
  // -------------------
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    primaryColor: appBarBackground,
    colorScheme: ColorScheme.light(
      primary: appBarBackground,
      secondary: buttonFill,
      surface: textFill,
      onPrimary: textFill,
      onSecondary: textFill,
      onSurface: textTitle,
    ),
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: appBarBackground,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textFill,
      ),
      iconTheme: IconThemeData(color: textFill),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonFill,
        foregroundColor: textFill,
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: buttonBorder),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: buttonFill,
        side: BorderSide(color: buttonBorder),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: textFill,
      hintStyle: const TextStyle(color: hintText),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: textBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: textBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: buttonFill, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: textFill,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: buttonFill,
      foregroundColor: textFill,
    ),
  );
}
