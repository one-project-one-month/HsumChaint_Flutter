import 'package:flutter/material.dart';
import 'package:hsum_chaint/data/models/ui_message.dart';

class AppUiHelper {
  /// Keys
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// ============================
  /// SNACKBAR
  /// ============================

  static void showMessage(UiMessage message) {
    switch (message.type) {
      case UiMessageType.error:
        showError(message.title, message.message);
        break;
      case UiMessageType.success:
        showSuccess(message.title, message.message);
        break;
      case UiMessageType.warning:
        showWarning(message.title, message.message);
        break;
      case UiMessageType.info:
        showInfo(message.title, message.message);
        break;
    }
  }

  static void showError(String title, String message) {
    _showSnackBar(
      title: title,
      message: message,
      backgroundColor: Colors.redAccent,
      icon: Icons.error,
    );
  }

  static void showSuccess(String title, String message) {
    _showSnackBar(
      title: title,
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  static void showWarning(String title, String message) {
    _showSnackBar(
      title: title,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning_amber_rounded,
    );
  }

  static void showInfo(String title, String message) {
    _showSnackBar(
      title: title,
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info_outline,
    );
  }

  static void _showSnackBar({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    messengerKey.currentState?.hideCurrentSnackBar();

    messengerKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$title\n$message',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ============================
  /// ALERT DIALOG
  /// ============================

  static Future<void> showAlert({
    required String title,
    required String message,
    String buttonText = 'OK',
    IconData icon = Icons.info_outline,
    Color iconColor = Colors.blue,
  }) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: iconColor.withOpacity(0.15),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }

  /// ============================
  /// CONFIRM DIALOG
  /// ============================

  static Future<void> showConfirm({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
  }) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// ============================
  /// LOADING
  /// ============================

  static void showLoading([String message = 'Loading...']) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  static void hideLoading() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
