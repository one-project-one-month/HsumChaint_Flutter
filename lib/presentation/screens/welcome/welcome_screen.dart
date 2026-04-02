import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hsum_chaint/core/navigation/app_routes.dart';
import 'package:hsum_chaint/features/authentication/widgets/register_popup_widget.dart';
import 'package:hsum_chaint/presentation/widgets/primary_button.dart';
import 'package:hsum_chaint/utils/extensions/animation_extensions.dart';
import 'package:hsum_chaint/utils/extensions/num_extensions.dart';
import 'package:hsum_chaint/utils/extensions/screen_extensions.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const _bgColor = Color(0xFFF6F2EC);
  static const _brandColor = Color(0xFFB45A09);
  static const _glowColor = Color(0xFFF6C06B);
  static const _subtitleColor = Color(0xFF555555);

  static const _bottomGlowDecoration = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0, 1.4), // bottom
      radius: 1.15,
      colors: [_glowColor, Color(0x66F6C06B), Color(0x00F6C06B)],
      stops: [0.2, 0.75, 1.0], // ✅ fixed (must be <= 1)
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 280,
              decoration: _bottomGlowDecoration,
            ).fadeIn(duration: 900.ms),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  120.h,

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/icons/app_logo.png',
                        width: 170,
                        height: 170,
                        fit: BoxFit.contain,
                      ).fadeScaleIn(duration: 900.ms, scaleBegin: 0.84),

                      4.h,

                      const Text(
                        'Swam Chaint',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _brandColor,
                          letterSpacing: 0.1,
                        ),
                      ).slideIn(
                        delay: 220.ms,
                        begin: const Offset(0, 0.18),
                        fadeBegin: 0,
                      ),
                    ],
                  ),

                  72.h,

                  const Text(
                    'Welcome',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ).slideIn(
                    delay: 320.ms,
                    begin: const Offset(0, 0.20),
                    fadeBegin: 0,
                  ),

                  28.h,

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Making meal donations simple and meaningful.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _subtitleColor,
                        height: 1.45,
                      ),
                    ),
                  ).slideIn(
                    delay: 430.ms,
                    begin: Offset(0, 0.20),
                    fadeBegin: 0,
                  ),

                  56.h,

                  PrimaryButton(
                    text: 'Login',
                    isLoading: false,
                    onPressed: () => context.push(AppRoutes.loginPath),
                  ).fadeIn(delay: 560.ms, duration: 700.ms),

                  20.h,

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton(
                      onPressed: () async {
                        final result = await showModalBottomSheet<String>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (_) => const RegisterAsBottomSheet(),
                        );

                        if (!context.mounted) return;

                        if (result == 'user') {
                          context.push(AppRoutes.userSignupPath);
                        } else if (result == 'monk') {
                          context.push(AppRoutes.monkSignupPath);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8F5F1),
                        side: const BorderSide(
                          color: Color(0xFFB9852B),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFB9852B),
                        ),
                      ),
                    ),
                  ).fadeIn(delay: 700.ms, duration: 700.ms),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    ).screen(context: context);
  }
}
