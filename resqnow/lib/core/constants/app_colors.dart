import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF00796B); // Teal
  static const Color accent = Color(0xFFD32F2F); // Red Alert
  static const Color secondary = Color(0xFFB71C1C); // Emergency Dark

  // Background and surface
  static const Color background = Color(0xFFFAFAFA); // Soft White
  static const Color cardShadow = Color.fromRGBO(0, 0, 0, 0.1); // Light Black

  // Text colors
  static const Color textPrimary = Color(0xFF212121); // Dark Gray
  static const Color textSecondary = Color(0xFF757575); // Muted Gray

  // Status indicators
  static const Color success = Color(0xFF388E3C); // Green
  static const Color warning = Color(0xFFFFA000); // Amber

  // Map-related (new additions)
  static const Color mapPin = Color(0xFF00796B); // same as primary
  static const Color mapPinSelected = Color(0xFFD32F2F); // accent/red
  static const Color userLocationCircle = Color(
    0x3300796B,
  ); // semi-transparent teal
}
