// edgeinsets_extensions.dart
import 'package:flutter/material.dart';

extension EdgeInsetsX on num {
  EdgeInsets get p => EdgeInsets.all(toDouble());
  EdgeInsets get px => EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsets get py => EdgeInsets.symmetric(vertical: toDouble());
}
/// Usage examples:
// padding: 16.p
// padding: 12.px