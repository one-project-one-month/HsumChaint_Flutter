import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hsum_chaint/features/authentication/controllers/auth_controller.dart';
import 'package:hsum_chaint/features/authentication/screens/forgotpwd_screen.dart';
import 'package:hsum_chaint/features/authentication/screens/resetpwd_screen.dart';
import 'package:hsum_chaint/presentation/widgets/custom_text_field.dart';
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
  final TextEditingController otpController = TextEditingController();
  final AuthController auth = Get.find<AuthController>();

  bool isCurrentPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  int _secondsLeft = 0;

  static const _fieldBorderColor = Color(0xFFB9852B);
  static const _hintColor = Color(0xFF9B9B9B);

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _secondsLeft = 60;
    Future.doWhile(() async {
      if (!mounted || _secondsLeft <= 0) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _secondsLeft--);
      return _secondsLeft > 0;
    });
  }

  Future<void> _requestOtp() async {
    if (_secondsLeft > 0) return;
    final success = await auth.requestChangePasswordOtp();
    if (success && mounted) {
      _startTimer();
    }
  }

  void _save() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final otp = otpController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar('Required', 'Please fill in all password fields');
      return;
    }

    if (otp.isEmpty || otp.length < 6) {
      Get.snackbar('Required', 'Please enter the 6-digit OTP code sent to your email');
      return;
    }

    if (newPassword.length < 6) {
      Get.snackbar(
        'Invalid',
        'Password must be at least 6 characters',
      );
      return;
    }

    if (!RegExp(r'^[\x21-\x7E]+$').hasMatch(currentPassword) ||
        !RegExp(r'^[\x21-\x7E]+$').hasMatch(newPassword)) {
      Get.snackbar(
        'Invalid',
        'Password must contain English characters and symbols only',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar('Invalid', 'Passwords do not match');
      return;
    }

    if (currentPassword == newPassword) {
      Get.snackbar('Invalid', 'New password cannot be the same as current password');
      return;
    }

    final success = await auth.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      otp: otp,
    );

    if (success && mounted) {
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => PasswordUpdatedBottomSheet(
          onGoToLogin: () {
            Navigator.pop(context);
            context.go('/login');
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PasswordPageWrapper(
        title: 'Change Password',
        buttonText: 'Save',
        isLoading: auth.isLoading.value,
        onPressed: _save,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            24.h,
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
              hintText: 'Enter your new password again',
              isVisible: isConfirmPasswordVisible,
              onToggle: () {
                setState(() {
                  isConfirmPasswordVisible = !isConfirmPasswordVisible;
                });
              },
            ),
            18.h,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const FieldLabel('Email Verification Code'),
                TextButton(
                  onPressed: _secondsLeft > 0 || auth.isOtpLoading.value
                      ? null
                      : _requestOtp,
                  child: Text(
                    _secondsLeft > 0
                        ? 'Resend (${_secondsLeft}s)'
                        : 'Get OTP',
                    style: const TextStyle(
                      color: Color(0xFFC05F0A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            6.h,
            CustomInputTextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              textStyle: const TextStyle(fontSize: 18, letterSpacing: 4, color: Colors.black),
              hintText: 'Enter 6-digit OTP',
              hintStyle: const TextStyle(
                fontSize: 16,
                letterSpacing: 0,
                color: _hintColor,
                fontWeight: FontWeight.w400,
              ),
              fillColor: Colors.transparent,
              borderColor: _fieldBorderColor,
              focusedBorderColor: _fieldBorderColor,
              borderRadius: 10,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              showClearButton: false,
            ),
            12.h,
            const Text(
              'A 6-digit code will be sent to your registered email for security.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            24.h,
          ],
        ),
      ),
    );
  }
}
