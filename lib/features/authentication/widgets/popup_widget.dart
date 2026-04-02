import 'package:flutter/material.dart';
import 'package:hsum_chaint/presentation/widgets/primary_button.dart';

class PopupWidget extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback? onPressed;

  const PopupWidget({
    super.key,
    required this.title,
    required this.buttonText,
    this.onPressed,
  });

  static const _bgColor = Color(0xFFF7F7F7);
  static const _textColor = Color(0xFF231B14);
  static const _successColor = Color(0xFF08C85A);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              const SizedBox(height: 42),

              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: _successColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _successColor.withOpacity(0.35),
                      blurRadius: 14,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 48),
              ),

              const SizedBox(height: 42),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 34),

              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: buttonText,
                  isLoading: false,
                  onPressed: onPressed ?? () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
