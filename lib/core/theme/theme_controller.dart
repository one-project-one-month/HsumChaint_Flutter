import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const preferenceKey = 'theme_mode';
  final _mode = ThemeMode.system.obs;
  ThemeMode get themeMode => _mode.value;
  bool get isDarkMode =>
      themeMode == ThemeMode.dark ||
      (themeMode == ThemeMode.system && Get.isPlatformDarkMode);

  @override
  void onInit() {
    super.onInit();
    final stored = Get.isRegistered<SharedPreferences>()
        ? Get.find<SharedPreferences>().getString(preferenceKey)
        : null;
    _mode.value = ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = Get.isRegistered<SharedPreferences>()
        ? Get.find<SharedPreferences>()
        : await SharedPreferences.getInstance();
    await prefs.setString(preferenceKey, mode.name);
    _mode.value = mode;
  }

  void toggleTheme() =>
      setThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
}
