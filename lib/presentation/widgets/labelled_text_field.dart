import 'package:flutter/material.dart';
import 'custom_text_field.dart';

class LabelledTextField extends StatelessWidget {
  const LabelledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final int maxLines;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F1A17),
          ),
        ),
        const SizedBox(height: 8),
        CustomInputTextField(
          controller: controller,
          hintText: hintText,
          maxLines: maxLines,
          keyboardType: keyboardType,
          borderRadius: 12,
          borderColor: const Color(0xFF9C6644), // Matches AppTheme.textBorder
          focusedBorderColor: const Color(0xFF9C6644),
          showClearButton: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          textStyle: const TextStyle(fontSize: 16, color: Color(0xFF1F1A17)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
