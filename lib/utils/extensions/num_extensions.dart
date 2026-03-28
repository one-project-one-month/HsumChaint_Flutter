import 'package:flutter/material.dart';

extension NumX on num {
  /// spacing
  SizedBox get h => SizedBox(height: toDouble());
  SizedBox get w => SizedBox(width: toDouble());

  /// duration
  Duration get ms => Duration(milliseconds: toInt());
  Duration get sec => Duration(seconds: toInt());
  Duration get min => Duration(minutes: toInt());
}
