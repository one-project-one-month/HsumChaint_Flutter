import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/icons/app_logo.png',
    width: size,
    height: size,
    fit: BoxFit.contain,
    semanticLabel: 'ဆွမ်းချိုင့် အမှတ်တံဆိပ်',
  );
}

class AppHeaderTitle extends StatelessWidget {
  final String title;
  const AppHeaderTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const AppLogo(),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}
