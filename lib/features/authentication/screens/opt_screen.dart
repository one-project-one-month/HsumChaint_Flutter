import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:hsum_chaint/core/navigation/app_routes.dart';
import 'package:hsum_chaint/features/authentication/controllers/auth_controller.dart';
import 'package:hsum_chaint/features/authentication/widgets/auth_common.dart';
import '../../../presentation/widgets/primary_button.dart';
import '../../../utils/extensions/extensions.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const _brandColor = Color(0xFFB45A09);
  static const _fieldBorderColor = Color(0xFFB9852B);
  static const _textColor = Color(0xFF1F1A17);
  static const _subtleTextColor = Color(0xFF3C342E);
  static const _timerColor = Color(0xFFC8892F);

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final AuthController _authController = Get.find<AuthController>();

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _secondsLeft = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      if (!mounted || _secondsLeft <= 0) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _secondsLeft--);
      return _secondsLeft > 0;
    });
  }

  String get _otp => _controllers.map((e) => e.text).join();

  void _onOtpChanged(String value, int index) {
    if (value.length > 1) {
      _controllers[index].text = value.substring(value.length - 1);
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    }

    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    setState(() {});
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  void _verifyOtp() {
    if (_otp.length < 6) {
      Get.snackbar('Invalid OTP', 'Please enter the 6-digit verification code');
      return;
    }
    // TODO: if api success, navigate to reset password screen Or Signup success page
    _authController.verifyOtp(phone: widget.phoneNumber, otp: _otp).then((
      success,
    ) {
      if (success && mounted) {
        context.go(AppRoutes.navigationPath);
      }
    });
  }

  void _resendOtp() {
    if (_secondsLeft > 0) return;

    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();

    setState(() {
      _secondsLeft = 60;
    });

    _startTimer();

    _authController.resendOtp(widget.phoneNumber);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 40,
      height: 52,
      child: KeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            _onBackspace(index);
          }
        },
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: Colors.transparent,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: _fieldBorderColor,
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: _fieldBorderColor,
                width: 1.6,
              ),
            ),
          ),
          onChanged: (value) => _onOtpChanged(value, index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          8.h,

          AuthPageHeader(
            title: 'OTP',
            onBack: () => context.pop(),
          ).slideIn(delay: 80.ms, begin: const Offset(0, -0.08), fadeBegin: 0),

          22.h,

          const AuthLogo(
            size: 130,
          ).fadeScaleIn(duration: 850.ms, scaleBegin: 0.86),

          26.h,

          const Text(
            'OPT Verification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ).slideIn(delay: 220.ms, begin: Offset(0, 0.10), fadeBegin: 0),

          20.h,

          const Text(
            'Enter the verification code we send.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textColor,
              height: 1.35,
            ),
          ).fadeIn(delay: 280.ms, duration: 600.ms),

          14.h,

          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                height: 1.45,
                color: _subtleTextColor,
              ),
              children: [
                const TextSpan(
                  text: 'Please type the code from the SMS we send to ',
                ),
                TextSpan(
                  text: widget.phoneNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _textColor,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ).fadeIn(delay: 340.ms, duration: 600.ms),

          18.h,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, _otpBox),
          ).fadeIn(delay: 420.ms, duration: 650.ms),

          20.h,

          Obx(
            () => PrimaryButton(
              text: 'Verify',
              isLoading: _authController.isOtpLoading.value,
              onPressed: _verifyOtp,
            ).fadeIn(delay: 520.ms, duration: 700.ms),
          ),

          18.h,

          Column(
            children: [
              const Text(
                'Didn’t received the code we send you?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: _subtleTextColor),
              ),
              6.h,
              GestureDetector(
                onTap: _resendOtp,
                child: Text(
                  _secondsLeft > 0
                      ? 'Resend in ${_secondsLeft}s.'
                      : 'Resend now',
                  style: TextStyle(
                    fontSize: 14,
                    color: _secondsLeft > 0 ? _timerColor : _brandColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ).fadeIn(delay: 620.ms, duration: 700.ms),

          40.h,
        ],
      ),
    );
  }
}
