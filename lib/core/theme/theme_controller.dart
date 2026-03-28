import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    // Initialize with system theme, or you could load from SharedPreferences
    _isDarkMode.value = Get.isPlatformDarkMode;
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;

    // Switch the theme
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    // Note: If you want to persist this, you can save the `_isDarkMode.value`
    // to SharedPreferences or GetStorage here.
  }
}
