import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsum_chaint/features/authentication/screens/forgotpwd_screen.dart';
import 'package:hsum_chaint/presentation/widgets/custom_text_field.dart';
import 'package:hsum_chaint/presentation/widgets/primary_button.dart';
import 'package:hsum_chaint/utils/extensions/num_extensions.dart';

class ForgotPasswordResetScreen extends StatefulWidget {
  const ForgotPasswordResetScreen({super.key});

  @override
  State<ForgotPasswordResetScreen> createState() =>
      _ForgotPasswordResetScreenState();
}

class _ForgotPasswordResetScreenState extends State<ForgotPasswordResetScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _save() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
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
      title: 'Forgot Password',
      buttonText: 'Save',
      onPressed: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          28.h,
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

class PasswordField extends StatelessWidget {
  const PasswordField({
    required this.controller,
    required this.hintText,
    required this.isVisible,
    required this.onToggle,
  });

  final TextEditingController controller;
  final String hintText;
  final bool isVisible;
  final VoidCallback onToggle;

  static const _fieldBorderColor = Color(0xFFB9852B);
  static const _hintColor = Color(0xFF9B9B9B);

  @override
  Widget build(BuildContext context) {
    return CustomInputTextField(
      controller: controller,
      textStyle: const TextStyle(fontSize: 16, color: Colors.black),
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 16,
        color: _hintColor,
        fontWeight: FontWeight.w400,
      ),
      fillColor: Colors.transparent,
      borderColor: _fieldBorderColor,
      focusedBorderColor: _fieldBorderColor,
      borderRadius: 10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      obscureText: !isVisible,
      showClearButton: false,
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: const Color(0xFF2E2419),
        ),
      ),
    );
  }
}

class PasswordUpdatedBottomSheet extends StatelessWidget {
  const PasswordUpdatedBottomSheet({super.key, required this.onGoToLogin});

  final VoidCallback onGoToLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              26.h,
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFF08C85A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 34),
              ),
              26.h,
              const Text(
                'Password updated !',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              24.h,
              PrimaryButton(
                text: 'Go to Login',
                isLoading: false,
                onPressed: onGoToLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
