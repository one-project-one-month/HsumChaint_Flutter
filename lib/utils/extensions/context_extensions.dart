import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  double get screenWidth => mediaQuery.size.width;

  double get screenHeight => mediaQuery.size.height;

  double get statusBarHeight => mediaQuery.padding.top;

  double get bottomBarHeight => mediaQuery.padding.bottom;

  void hideKeyboard() => FocusScope.of(this).unfocus();

  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }
}
