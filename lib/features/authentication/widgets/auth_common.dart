import 'package:flutter/material.dart';

/// Shared styling used across authentication screens to avoid duplicate
/// widget definitions. The layout and colors mirror the original designs.
abstract final class AuthColors {
  static const Color background = Color(0xFFF6F2EC);
  static const Color brand = Color(0xFFB45A09);
  static const Color glow = Color(0xFFF2CC87);
  static const Color fieldBorder = Color(0xFFB9852B);
  static const Color hint = Color(0xFF9B9B9B);
  static const Color required = Color(0xFFFF4D4F);
}

const _topDecoration = BoxDecoration(
  gradient: RadialGradient(
    center: Alignment(0, -1.2),
    radius: 1.15,
    colors: [AuthColors.glow, Color(0x66F2CC87), Color(0x00F2CC87)],
    stops: [0.2, 0.75, 1.0],
  ),
);

class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(decoration: _topDecoration),
          ),
          SafeArea(
            child: SingleChildScrollView(padding: padding, child: child),
          ),
        ],
      ),
    );
  }
}

class AuthPageHeader extends StatelessWidget {
  const AuthPageHeader({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 22,
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, this.size = 150});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icons/app_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 6),
        const Text(
          'Swam Chaint',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AuthColors.brand,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class AuthSectionTitle extends StatelessWidget {
  const AuthSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(
    this.text, {
    super.key,
    this.required = false,
    this.trailing,
  });

  final String text;
  final bool required;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: AuthColors.required,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (trailing != null)
            TextSpan(
              text: ' ($trailing)',
              style: const TextStyle(
                color: Color(0xFF8C8C8C),
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}
