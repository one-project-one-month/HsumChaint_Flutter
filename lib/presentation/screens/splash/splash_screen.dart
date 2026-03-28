import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hsum_chaint/presentation/screens/splash/splash_controller.dart';
import 'package:hsum_chaint/utils/extensions/extensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final SplashController controller;

  static const _textColor = Color(0xFFB45A09);
  static const _glowColor = Color(0xFFF8C16A);

  static const _bottomGlowDecoration = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0, 1.4), // bottom
      radius: 1.15,
      colors: [_glowColor, Color(0x66F6C06B), Color(0x00F6C06B)],
      stops: [0.2, 0.75, 1.0], // ✅ fixed (must be <= 1)
    ),
  );

  @override
  void initState() {
    super.initState();
    controller = Get.find<SplashController>();
    _navigate();
  }

  Future<void> _navigate() async {
    final nextRoute = await controller.getNextRoute();
    if (!mounted) return;
    context.go(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 260,
            decoration: _bottomGlowDecoration,
          ).fadeIn(duration: 900.ms),
        ),
        SafeArea(
          child: Center(
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/app_logo.png',
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                  ).fadeScaleIn(duration: 900.ms, scaleBegin: 0.82),
                  18.h,
                  const Text(
                    'Swam Chaint',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                      letterSpacing: 0.2,
                    ),
                  ).slideIn(
                    delay: 250.ms,
                    begin: const Offset(0, 0.22),
                    fadeBegin: 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ).screen(context: context);
  }
}
