import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsum_chaint/core/navigation/app_routes.dart';
import 'package:hsum_chaint/features/authentication/controllers/auth_controller.dart';
import 'package:hsum_chaint/presentation/widgets/custom_text_field.dart';
import 'package:hsum_chaint/utils/extensions/num_extensions.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/widgets/primary_button.dart';

class ForgotPasswordPhoneScreen extends StatefulWidget {
  const ForgotPasswordPhoneScreen({super.key});

  @override
  State<ForgotPasswordPhoneScreen> createState() =>
      _ForgotPasswordPhoneScreenState();
}

class _ForgotPasswordPhoneScreenState extends State<ForgotPasswordPhoneScreen> {
  final TextEditingController emailController = TextEditingController();
  final AuthController auth = Get.find<AuthController>();

  static const _fieldBorderColor = Color(0xFFB9852B);
  static const _hintColor = Color(0xFF9B9B9B);

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar('Required', 'Please enter a valid email address');
      return;
    }

    final success = await auth.forgotPassword(email);
    if (success && mounted) {
      context.push(
        AppRoutes.optPath,
        extra: {
          'destination': email,
          'purpose': 'RESET_PASSWORD',
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PasswordPageWrapper(
        title: 'Forgot Password',
        buttonText: 'Send Verification Code',
        isLoading: auth.isLoading.value,
        onPressed: _submitEmail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            28.h,
            const FieldLabel('Email Address'),
            10.h,
            CustomInputTextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textStyle: const TextStyle(fontSize: 16, color: Colors.black),
              hintText: 'Enter your email address',
              hintStyle: const TextStyle(
                fontSize: 16,
                color: _hintColor,
                fontWeight: FontWeight.w400,
              ),
              fillColor: Colors.transparent,
              borderColor: _fieldBorderColor,
              focusedBorderColor: _fieldBorderColor,
              borderRadius: 10,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              showClearButton: false,
            ),
            12.h,
            const Text(
              'Please enter the email address you used when\ncreating your account.',
              style: TextStyle(fontSize: 14, color: Colors.black, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordPageWrapper extends StatelessWidget {
  const PasswordPageWrapper({
    super.key,
    required this.title,
    required this.child,
    required this.buttonText,
    required this.onPressed,
    this.isLoading = false,
  });

  final String title;
  final Widget child;
  final String buttonText;
  final VoidCallback onPressed;
  final bool isLoading;

  static const _bgColor = Color(0xFFF6F2EC);
  static const _glowColor = Color(0xFFF2CC87);

  static const _topDecoration = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0, -1.2),
      radius: 1.15,
      colors: [_glowColor, Color(0x66F2CC87), Color(0x00F2CC87)],
      stops: [0.2, 0.75, 1.0],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(decoration: _topDecoration),
          ),
          SafeArea(
            child: Column(
              children: [
                8.h,
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: child,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: PrimaryButton(
                    text: buttonText,
                    isLoading: isLoading,
                    onPressed: onPressed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }
}
