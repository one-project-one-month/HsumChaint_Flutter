import 'package:flutter/material.dart';

class CustomInputTextField extends StatelessWidget {
  final bool visible;
  final TextEditingController controller;
  final FocusNode? focusNode;

  // Callbacks
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  // Text behavior
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final bool autofocus;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;

  // UI
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Color cursorColor;
  final Color fillColor;
  final Color borderColor;
  final Color focusedBorderColor;
  final double borderRadius;
  final EdgeInsets contentPadding;

  // Icons
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showClearButton;

  // Size
  final double? height;
  final double? width;

  // Key
  final GlobalKey<FormFieldState>? fieldKey;

  // Password
  final bool obscureText;

  const CustomInputTextField({
    super.key,
    required this.controller,
    this.visible = true,
    this.focusNode,

    // Callbacks
    this.onEditingComplete,
    this.onChanged,
    this.onClear,

    // Text behavior
    this.textInputAction = TextInputAction.done,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,

    // UI
    this.hintText,
    this.hintStyle,
    this.textStyle,
    this.cursorColor = Colors.black,
    this.fillColor = Colors.white,
    this.borderColor = Colors.grey,
    this.focusedBorderColor = const Color.fromARGB(255, 200, 174, 4),
    this.borderRadius = 8,
    this.contentPadding = const EdgeInsets.symmetric(
      vertical: 10,
      horizontal: 12,
    ),

    // Icons
    this.prefixIcon,
    this.suffixIcon,
    this.showClearButton = true,

    // Size
    this.height,
    this.width,

    // Key
    this.fieldKey,

    // Password
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      controller.clear();
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: height,
      width: width ?? MediaQuery.of(context).size.width,
      child: TextFormField(
        key: fieldKey,
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        readOnly: readOnly,
        maxLines: maxLines,
        maxLength: maxLength,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        cursorColor: cursorColor,
        style: textStyle,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: fillColor,
          hintText: hintText,
          hintStyle: hintStyle,
          contentPadding: contentPadding,
          prefixIcon: prefixIcon,
          suffixIcon: showClearButton
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 16,
                    color: controller.text.isNotEmpty
                        ? focusedBorderColor
                        : Colors.grey[300],
                  ),
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                    onEditingComplete?.call();
                  },
                )
              : suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: focusedBorderColor, width: 2),
          ),
        ),
      ),
    );
  }
}
