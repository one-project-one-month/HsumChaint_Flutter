import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hsum_chaint/features/authentication/widgets/popup_widget.dart';
import 'package:hsum_chaint/features/authentication/widgets/auth_common.dart';
import 'package:hsum_chaint/presentation/widgets/custom_text_field.dart';
import '../../../core/navigation/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../../../presentation/widgets/primary_button.dart';
import '../../../utils/extensions/extensions.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  static const _fieldBorderColor = Color(0xFFB9852B);
  static const _hintColor = Color(0xFF9B9B9B);

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            8.h,

            AuthPageHeader(
              title: 'Log In',
              onBack: () => context.pop(),
            ).slideIn(
              delay: 80.ms,
              begin: const Offset(0, -0.08),
              fadeBegin: 0,
            ),

            26.h,

            const AuthLogo().fadeScaleIn(duration: 850.ms, scaleBegin: 0.86),

            28.h,

            const Text(
              'Phone Number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ).slideIn(
              delay: 240.ms,
              begin: const Offset(0, 0.12),
              fadeBegin: 0,
            ),

            12.h,

            CustomInputTextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              textStyle: const TextStyle(fontSize: 16, color: Colors.black),
              hintText: 'Enter your phone number',
              hintStyle: const TextStyle(
                fontSize: 16,
                color: _hintColor,
                fontWeight: FontWeight.w400,
              ),
              fillColor: Colors.transparent,
              borderColor: _fieldBorderColor,
              focusedBorderColor: _fieldBorderColor,
              borderRadius: 14,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              showClearButton: false,
            ).fadeIn(delay: 300.ms, duration: 700.ms),

            24.h,

            const Text(
              'Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ).slideIn(
              delay: 340.ms,
              begin: const Offset(0, 0.12),
              fadeBegin: 0,
            ),

            12.h,

            Obx(
              () => CustomInputTextField(
                controller: controller.passwordController,
                textStyle: const TextStyle(fontSize: 16, color: Colors.black),
                hintText: 'Enter your password',
                hintStyle: const TextStyle(
                  fontSize: 16,
                  color: _hintColor,
                  fontWeight: FontWeight.w400,
                ),
                fillColor: Colors.transparent,
                borderColor: _fieldBorderColor,
                focusedBorderColor: _fieldBorderColor,
                borderRadius: 14,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
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
              ).fadeIn(delay: 400.ms, duration: 700.ms),
            ),

            12.h,

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(AppRoutes.forgotPasswordPath),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFC05F0A),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFFC05F0A),
                  ),
                ),
              ),
            ).fadeIn(delay: 470.ms, duration: 650.ms),

            28.h,

            Obx(
              () => PrimaryButton(
                text: 'Login',
                isLoading: controller.isLoading.value,
                onPressed: () {
                  final phone = controller.phoneController.text.trim();
                  final password = controller.passwordController.text.trim();

                  if (phone.isEmpty) {
                    Get.snackbar('Required', 'Phone number is required');
                    return;
                  }

                  if (password.isEmpty) {
                    Get.snackbar('Required', 'Password is required');
                    return;
                  }

                  if (password.length < 6) {
                    Get.snackbar(
                      'Invalid',
                      'Password must be at least 6 characters',
                    );
                    return;
                  }

                  controller.login();
                  controller.isLoginSuccessful.listen((isSuccess) {
                    if (isSuccess) {
                      context.go(AppRoutes.homePath);
                    }
                  });
                },
              ).fadeIn(delay: 560.ms, duration: 700.ms),
            ),

            52.h,

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Doesn’t have an account? ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    controller.clearControllers();

                    final result = await showModalBottomSheet<String>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => const RegisterAsBottomSheet(),
                    );

                    if (result == 'user') {
                      if (context.mounted) {
                        context.push(AppRoutes.userSignupPath);
                      }
                    } else if (result == 'monk') {
                      if (context.mounted) {
                        context.push(AppRoutes.monkSignupPath);
                      }
                    }
                  },
                  child: const Text(
                    'Sign Up',
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
            ).fadeIn(delay: 680.ms, duration: 700.ms),

            40.h,
          ],
        ),
      ),
    );
  }
}
