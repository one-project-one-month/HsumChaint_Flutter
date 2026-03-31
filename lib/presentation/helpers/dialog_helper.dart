import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogHelper {
  /// Show error dialog
  static void showErrorDialog({
    String title = 'Error',
    String description = 'Something went wrong',
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () {
              if (Get.isDialogOpen ?? false) Get.back();
            },
            child: const Text('OK'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Show loading dialog
  static void showLoading([String message = 'Loading...']) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(message, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Hide loading dialog
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// Show confirmation / prompt dialog
  static void showPromptDialog({
    required String title,
    required String description,
    required VoidCallback onConfirm,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmTextColor,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(description),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () {
              if (Get.isDialogOpen ?? false) Get.back();
            },
            child: Text(cancelText, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (Get.isDialogOpen ?? false) Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  confirmTextColor ??
                  (Get.context != null
                      ? Theme.of(Get.context!).primaryColor
                      : Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    required Icon icon,
  }) {
    try {
      Get.closeCurrentSnackbar();
    } catch (_) {
      // Ignore if snackbar controller is not yet initialized.
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context == null) return;

      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: backgroundColor,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: icon,
        duration: const Duration(seconds: 3),
      );
    });
  }

  static void showErrorSnackbar({
    required String title,
    required String message,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.redAccent,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  static void showSuccessSnackbar({
    required String title,
    required String message,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.green,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }
}
