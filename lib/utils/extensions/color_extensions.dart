// color_extensions.dart
import 'package:flutter/material.dart';

extension ColorX on Color {
  String get toHex {
    final argb = toARGB32();
    return '#${argb.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  bool get isDark => computeLuminance() < 0.5;

  Color withOpacityPercent(int percent) {
    final clamped = percent.clamp(0, 100);
    final alphaValue = (255 * (clamped / 100)).round();
    return withAlpha(alphaValue);
  }
}
