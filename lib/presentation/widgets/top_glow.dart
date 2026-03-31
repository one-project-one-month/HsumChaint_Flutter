import 'package:flutter/material.dart';

class TopGlow extends StatelessWidget {
  const TopGlow({super.key, this.height = 260});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -1.2),
          radius: 1.5,
          colors: [
            Color(0xFFF2CC87),
            Color(0x99F2CC87),
            Color(0x00F2CC87),
          ],
          stops: [0.1, 0.4, 0.8],
        ),
      ),
    );
  }
}
