import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsum_chaint/core/theme/theme_controller.dart';
import 'package:hsum_chaint/features/authentication/controllers/auth_controller.dart';
import 'package:hsum_chaint/utils/extensions/extensions.dart';

class HomeScreen extends GetView<AuthController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          Obx(
            () => IconButton(
              onPressed: themeController.toggleTheme,
              icon: Icon(
                themeController.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
          ),
          IconButton(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            final user = controller.currentUser.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are signed in.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                12.h,
                Text(
                  user?.name ?? 'Guest',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                8.h,
                Text(
                  user?.email ?? 'No email available',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                24.h,
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Navigation is handled by go_router, while GetX manages dependency injection, dialogs, snackbars, and auth state.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                24.h,
                ElevatedButton.icon(
                  onPressed: controller.logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
