import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    background: AppColors.background,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.textPrimary,
    error: AppColors.warning,
    onError: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    color: AppColors.primary,
    iconTheme: IconThemeData(color: Colors.white),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: AppTextStyles.appTitle.copyWith(color: Colors.white),
  ),
  textTheme: TextTheme(
    titleLarge: AppTextStyles.appTitle,
    titleMedium: AppTextStyles.sectionTitle,
    bodyLarge: AppTextStyles.bodyText,
    bodyMedium: AppTextStyles.bodyText,
    labelLarge: AppTextStyles.buttonText,
    labelSmall: AppTextStyles.caption,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      textStyle: AppTextStyles.buttonText,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
  dividerTheme: DividerThemeData(
    color: AppColors.textSecondary.withOpacity(0.3),
    thickness: 1,
  ),
);
