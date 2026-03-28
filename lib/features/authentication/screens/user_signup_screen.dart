import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';
import '../widgets/auth_common.dart';
import '../controllers/auth_controller.dart';
import '../../../presentation/widgets/custom_text_field.dart';
import '../../../presentation/widgets/primary_button.dart';
import '../../../utils/extensions/extensions.dart';

class UserSignUpScreen extends GetView<AuthController> {
  const UserSignUpScreen({super.key});

  Future<void> _submit(BuildContext context) async {
    final phone = controller.phoneController.text.trim();
    final username = controller.usernameController.text.trim();
    final password = controller.passwordController.text.trim();
    final confirmPassword = controller.confirmPasswordController.text.trim();

    if (phone.isEmpty) {
      Get.snackbar('Required', 'Phone number is required');
      return;
    }

    if (username.isEmpty) {
      Get.snackbar('Required', 'Username is required');
      return;
    }

    if (password.isEmpty) {
      Get.snackbar('Required', 'Password is required');
      return;
    }

    if (password.length < 6) {
      Get.snackbar('Invalid', 'Password must be at least 6 characters');
      return;
    }

    if (confirmPassword.isEmpty) {
      Get.snackbar('Required', 'Confirm password is required');
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('Invalid', 'Passwords do not match');
      return;
    }

    final success = await controller.signupUser();
    if (!context.mounted) return;

    if (success) {
      context.pushNamed(
        AppRoutes.optName,
        pathParameters: {'phone': phone},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          8.h,

          AuthPageHeader(
            title: 'Sign Up',
            onBack: () => context.pop(),
          ).slideIn(
            delay: 80.ms,
            begin: const Offset(0, -0.08),
            fadeBegin: 0,
          ),

          20.h,

          const AuthLogo(size: 130)
              .fadeScaleIn(duration: 850.ms, scaleBegin: 0.86),

          22.h,

          const AuthSectionTitle('Account Information').slideIn(
            delay: 220.ms,
            begin: Offset(0, 0.12),
            fadeBegin: 0,
          ),

          20.h,

          const AuthFieldLabel('Phone Number', required: true).slideIn(
            delay: 260.ms,
            begin: Offset(0, 0.10),
            fadeBegin: 0,
          ),

          10.h,

          CustomInputTextField(
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            textStyle: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            hintText: 'Enter your phone number',
            hintStyle: const TextStyle(
              fontSize: 16,
              color: AuthColors.hint,
              fontWeight: FontWeight.w400,
            ),
            fillColor: Colors.transparent,
            borderColor: AuthColors.fieldBorder,
            focusedBorderColor: AuthColors.fieldBorder,
            borderRadius: 12,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            showClearButton: false,
          ).fadeIn(delay: 300.ms, duration: 650.ms),

          18.h,

          const AuthFieldLabel('Username').slideIn(
            delay: 330.ms,
            begin: Offset(0, 0.10),
            fadeBegin: 0,
          ),

          10.h,

          CustomInputTextField(
            controller: controller.usernameController,
            textStyle: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            hintText: 'Set your username',
            hintStyle: const TextStyle(
              fontSize: 16,
              color: AuthColors.hint,
              fontWeight: FontWeight.w400,
            ),
            fillColor: Colors.transparent,
            borderColor: AuthColors.fieldBorder,
            focusedBorderColor: AuthColors.fieldBorder,
            borderRadius: 12,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            showClearButton: false,
          ).fadeIn(delay: 360.ms, duration: 650.ms),

          18.h,

          const AuthFieldLabel('Password', required: true).slideIn(
            delay: 390.ms,
            begin: Offset(0, 0.10),
            fadeBegin: 0,
          ),

          10.h,

          Obx(
            () => CustomInputTextField(
              controller: controller.passwordController,
              textStyle: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              hintText: 'Enter your password',
              hintStyle: const TextStyle(
                fontSize: 16,
                color: AuthColors.hint,
                fontWeight: FontWeight.w400,
              ),
              fillColor: Colors.transparent,
              borderColor: AuthColors.fieldBorder,
              focusedBorderColor: AuthColors.fieldBorder,
              borderRadius: 12,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              obscureText: !controller.isPasswordVisible.value,
              showClearButton: false,
              suffixIcon: IconButton(
                onPressed: controller.togglePasswordVisibility,
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF2E2419),
                ),
              ),
            ).fadeIn(delay: 420.ms, duration: 650.ms),
          ),

          18.h,

          const AuthFieldLabel('Confirm Password', required: true).slideIn(
            delay: 450.ms,
            begin: Offset(0, 0.10),
            fadeBegin: 0,
          ),

          10.h,

          Obx(
            () => CustomInputTextField(
              controller: controller.confirmPasswordController,
              textStyle: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              hintText: 'Enter your password',
              hintStyle: const TextStyle(
                fontSize: 16,
                color: AuthColors.hint,
                fontWeight: FontWeight.w400,
              ),
              fillColor: Colors.transparent,
              borderColor: AuthColors.fieldBorder,
              focusedBorderColor: AuthColors.fieldBorder,
              borderRadius: 12,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              obscureText: !controller.isConfirmPasswordVisible.value,
              showClearButton: false,
              suffixIcon: IconButton(
                onPressed: controller.toggleConfirmPasswordVisibility,
                icon: Icon(
                  controller.isConfirmPasswordVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF2E2419),
                ),
              ),
            ).fadeIn(delay: 480.ms, duration: 650.ms),
          ),

          24.h,

          const AuthSectionTitle('Contact Information').slideIn(
            delay: 520.ms,
            begin: Offset(0, 0.10),
            fadeBegin: 0,
          ),

          18.h,

          const AuthFieldLabel('Email Address', trailing: 'optional').slideIn(
            delay: 560.ms,
            begin: Offset(0, 0.10),
            fadeBegin: 0,
          ),

          10.h,

          CustomInputTextField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            textStyle: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            hintText: 'Enter your email address',
            hintStyle: const TextStyle(
              fontSize: 16,
              color: AuthColors.hint,
              fontWeight: FontWeight.w400,
            ),
            fillColor: Colors.transparent,
            borderColor: AuthColors.fieldBorder,
            focusedBorderColor: AuthColors.fieldBorder,
            borderRadius: 12,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            showClearButton: false,
          ).fadeIn(delay: 600.ms, duration: 650.ms),

          18.h,

          const AuthFieldLabel('Phone Number', trailing: 'optional').slideIn(
            delay: 630.ms,
            begin: Offset(0, 0.10),
            fadeBegin: 0,
          ),

          10.h,

          CustomInputTextField(
            controller: controller.contactPhoneController,
            keyboardType: TextInputType.phone,
            textStyle: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            hintText: 'Enter your phone number',
            hintStyle: const TextStyle(
              fontSize: 16,
              color: AuthColors.hint,
              fontWeight: FontWeight.w400,
            ),
            fillColor: Colors.transparent,
            borderColor: AuthColors.fieldBorder,
            focusedBorderColor: AuthColors.fieldBorder,
            borderRadius: 12,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            showClearButton: false,
          ).fadeIn(delay: 660.ms, duration: 650.ms),

          28.h,

          Obx(
            () => PrimaryButton(
              text: 'Sign Up',
              isLoading: controller.isLoading.value,
          onPressed: () => _submit(context),
        ).fadeIn(delay: 720.ms, duration: 700.ms),
      ),

          24.h,

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              GestureDetector(
                onTap: () {
                  controller.clearControllers();
                  context.pushNamed(AppRoutes.loginName);
                },
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFC05F0A),
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFFC05F0A),
                  ),
                ),
              ),
            ],
          ).fadeIn(delay: 780.ms, duration: 700.ms),

          32.h,
        ],
      ),
    );
  }
}
