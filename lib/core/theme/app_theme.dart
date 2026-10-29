import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFFB45A09);
  static const primaryContainer = Color(0xFFFEF3C7);
  static const onPrimaryContainer = Color(0xFF78350F);
  static const secondary = Color(0xFFD97706);
  static const scaffoldBackgroundLight = Color(0xFFFBF9F5);
  static const scaffoldBackgroundDark = Color(0xFF171412);
  static const surfaceLight = Colors.white;
  static const surfaceDark = Color(0xFF241E1A);
  static const borderLight = Color(0xFFEFE6DC);
  static const borderDark = Color(0xFF3D332A);
  static const textPrimaryLight = Color(0xFF1C1917);
  // Slightly deeper than the reference to meet AA on linen and white.
  static const textSecondaryLight = Color(0xFF706862);
  static const textPrimaryDark = Color(0xFFF5F5F4);
  static const textSecondaryDark = Color(0xFFA8A29E);
}

class AppTheme {
  static const background = AppColors.scaffoldBackgroundLight;
  static const textBorder = AppColors.borderLight;
  static const textFill = AppColors.surfaceLight;
  static const textTitle = AppColors.textPrimaryLight;
  static const hintText = AppColors.textSecondaryLight;
  static const buttonFill = AppColors.primary;
  static const buttonBorder = AppColors.primary;
  static const appBarBackground = AppColors.surfaceLight;
  static final lightTheme = _build(Brightness.light);
  static final darkTheme = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final surface = dark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = dark ? AppColors.borderDark : AppColors.borderLight;
    final text = dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final muted = dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: dark ? const Color(0xFFF3B66B) : AppColors.primary,
          onPrimary: dark ? const Color(0xFF3B2008) : Colors.white,
          primaryContainer: dark
              ? const Color(0xFF51331A)
              : AppColors.primaryContainer,
          onPrimaryContainer: dark
              ? AppColors.primaryContainer
              : AppColors.onPrimaryContainer,
          secondary: dark ? const Color(0xFFF2C574) : AppColors.secondary,
          onSecondary: dark ? const Color(0xFF392300) : const Color(0xFF241500),
          surface: surface,
          onSurface: text,
          onSurfaceVariant: muted,
          outline: dark ? const Color(0xFF9C8B7D) : const Color(0xFF8A7868),
          outlineVariant: border,
        );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Padauk',
      colorScheme: scheme,
    );
    final textTheme = base.textTheme.apply(bodyColor: text, displayColor: text);
    return base.copyWith(
      scaffoldBackgroundColor: dark
          ? AppColors.scaffoldBackgroundDark
          : background,
      textTheme: textTheme.map((style) => style.copyWith(height: 1.35)),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: AppColors.onPrimaryContainer.withValues(alpha: .08),
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: muted),
        labelStyle: TextStyle(color: muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(48, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: scheme.primary,
        textColor: scheme.onPrimary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: DividerThemeData(color: border),
    );
  }
}

extension on TextTheme {
  TextTheme map(TextStyle Function(TextStyle) transform) => copyWith(
    displayLarge: transform(displayLarge!),
    displayMedium: transform(displayMedium!),
    displaySmall: transform(displaySmall!),
    headlineLarge: transform(headlineLarge!),
    headlineMedium: transform(headlineMedium!),
    headlineSmall: transform(headlineSmall!),
    titleLarge: transform(titleLarge!),
    titleMedium: transform(titleMedium!),
    titleSmall: transform(titleSmall!),
    bodyLarge: transform(bodyLarge!),
    bodyMedium: transform(bodyMedium!),
    bodySmall: transform(bodySmall!),
    labelLarge: transform(labelLarge!),
    labelMedium: transform(labelMedium!),
    labelSmall: transform(labelSmall!),
  );
}
