// screen_extensions.dart
import 'package:flutter/material.dart';

extension ScreenX on Widget {
  // double get w => MediaQuery.of(this).size.width;
  // double get h => MediaQuery.of(this).size.height;

  Widget screen({
    required BuildContext context, // pass context explicitly
    PreferredSizeWidget? appBar,
    //bool isHome = false,
    EdgeInsets? padding, // optional, calculated inside
    bool hasDrawer = false,
    Widget? floatingActionButton,
    Widget? drawer,
  }) {
    final effectivePadding = padding ?? EdgeInsets.all(0);

    return Scaffold(
      backgroundColor: //isHome
          // ? Colors.transparent
          //  :
          hasDrawer ? Theme.of(context).scaffoldBackgroundColor : null,
      drawer: hasDrawer ? drawer : null,
      appBar: appBar,

      body: Padding(padding: effectivePadding, child: this),
      floatingActionButton: floatingActionButton,
    );
  }
}
