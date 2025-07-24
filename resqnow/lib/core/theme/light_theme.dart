import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: Colors.white,
    background: AppColors.background,
    error: AppColors.warning,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.textPrimary,
    onError: Colors.white,
    onBackground: AppColors.textPrimary,
  ),
  appBarTheme: AppBarTheme(
    color: AppColors.primary,
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
    labelSmall: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.accent,
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
  iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
  dividerTheme: const DividerThemeData(
    color: Color.fromRGBO(117, 117, 117, 0.3), // Muted Gray with 30% opacity
    thickness: 1,
  ),
);
