import 'package:flutter/material.dart';

class RegisterAsBottomSheet extends StatelessWidget {
  const RegisterAsBottomSheet({super.key});

  static const _bgColor = Color(0xFFF7F7F7);
  static const _textColor = Color(0xFF231B14);

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
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Register as',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _RegisterTypeCard(
                      icon: 'assets/icons/user.png',
                      label: 'User',
                      onTap: () {
                        Navigator.pop(context, 'user');
                      },
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _RegisterTypeCard(
                      icon: 'assets/icons/monk.png',
                      label: 'Monk',
                      onTap: () {
                        Navigator.pop(context, 'monk');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterTypeCard extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _RegisterTypeCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  static const _textColor = Color(0xFF231B14);
  static const _borderColor = Color(0xFFAFAFAF);
  static const _iconColor = Color(0xFF6C6764);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _borderColor, width: 1.8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icon, color: _iconColor),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  // fontWeight: FontWeight.w500,
                  color: _textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
