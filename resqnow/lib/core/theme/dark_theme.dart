import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  primaryColor: AppColors.secondary,
  colorScheme: ColorScheme.dark(
    primary: AppColors.secondary,
    secondary: AppColors.accent,
    surface: Colors.grey[900]!,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    error: AppColors.warning,
    onError: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    color: AppColors.secondary,
    iconTheme: IconThemeData(color: Colors.white),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: AppTextStyles.appTitle.copyWith(color: Colors.white),
  ),
  textTheme: TextTheme(
    titleLarge: AppTextStyles.appTitle.copyWith(color: Colors.white),
    titleMedium: AppTextStyles.sectionTitle.copyWith(color: Colors.white),
    bodyLarge: AppTextStyles.bodyText.copyWith(color: Colors.white),
    bodyMedium: AppTextStyles.bodyText.copyWith(color: Colors.white),
    labelLarge: AppTextStyles.buttonText,
    labelSmall: AppTextStyles.caption.copyWith(color: Colors.grey[400]),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.secondary,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      textStyle: AppTextStyles.buttonText,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  iconTheme: IconThemeData(color: Colors.white, size: 24),
  dividerTheme: DividerThemeData(
    color: Colors.white.withValues(alpha: 0.3),
    thickness: 1,
  ),
);
