import 'package:flutter/material.dart';
import 'package:resqnow/core/constants/app_text_styles.dart';
import 'package:resqnow/core/constants/app_colors.dart';

class AdminInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AdminInputField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
