import 'package:flutter/material.dart';
import 'package:resqnow/core/constants/app_text_styles.dart';
import 'package:resqnow/core/constants/app_colors.dart';

class AdminSectionTitle extends StatelessWidget {
  final String title;

  const AdminSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary),
      ),
    );
  }
}
