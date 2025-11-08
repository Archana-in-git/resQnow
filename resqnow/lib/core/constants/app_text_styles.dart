// app_text_styles.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Titles
  static const TextStyle appTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Buttons
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Body text
  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  // Captions / labels
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: AppColors.textSecondary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Additional styles
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
}
