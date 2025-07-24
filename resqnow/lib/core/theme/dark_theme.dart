import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  primaryColor: AppColors.primary,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: Color(0xFF121212),
    background: Colors.black,
    error: AppColors.warning,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.white,
    onBackground: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    color: AppColors.secondary,
    iconTheme: const IconThemeData(color: Colors.white),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: AppTextStyles.appTitle.copyWith(color: Colors.white),
  ),
  textTheme: TextTheme(
    titleLarge: AppTextStyles.appTitle.copyWith(color: AppColors.textPrimary),
    titleMedium: AppTextStyles.sectionTitle.copyWith(
      color: AppColors.textPrimary,
    ),
    bodyLarge: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
    bodyMedium: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
    labelLarge: AppTextStyles.buttonText.copyWith(color: Colors.white),
    labelSmall: AppTextStyles.caption.copyWith(color: Colors.grey[400]),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.accent,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      textStyle: AppTextStyles.buttonText,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.white, size: 24),
  dividerTheme: DividerThemeData(
    color: Colors.white.withOpacity(0.3),
    thickness: 1,
  ),
);
