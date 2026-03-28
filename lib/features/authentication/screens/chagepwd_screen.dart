import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsum_chaint/features/authentication/screens/forgotpwd_screen.dart';
import 'package:hsum_chaint/features/authentication/screens/resetpwd_screen.dart';
import 'package:hsum_chaint/utils/extensions/num_extensions.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isCurrentPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _save() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar('Required', 'Please fill in all fields');
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar('Invalid', 'Passwords do not match');
      return;
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PasswordUpdatedBottomSheet(
        onGoToLogin: () {
          Navigator.pop(context);
          // context.go('/login');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PasswordPageWrapper(
      title: 'Change Password',
      buttonText: 'Save',
      onPressed: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          28.h,
          const FieldLabel('Current Password'),
          10.h,
          PasswordField(
            controller: currentPasswordController,
            hintText: 'Enter your current password',
            isVisible: isCurrentPasswordVisible,
            onToggle: () {
              setState(() {
                isCurrentPasswordVisible = !isCurrentPasswordVisible;
              });
            },
          ),
          18.h,
          const FieldLabel('New Password'),
          10.h,
          PasswordField(
            controller: newPasswordController,
            hintText: 'Enter your new password',
            isVisible: isNewPasswordVisible,
            onToggle: () {
              setState(() {
                isNewPasswordVisible = !isNewPasswordVisible;
              });
            },
          ),
          18.h,
          const FieldLabel('Confirm Password'),
          10.h,
          PasswordField(
            controller: confirmPasswordController,
            hintText: 'Enter your password',
            isVisible: isConfirmPasswordVisible,
            onToggle: () {
              setState(() {
                isConfirmPasswordVisible = !isConfirmPasswordVisible;
              });
            },
          ),
        ],
      ),
    );
  }
}
