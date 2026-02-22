import 'package:flutter/material.dart';

/// App color palette — dark, cold, high-contrast
class AppColors {
  static const background = Color(0xFF0A0A0A);
  static const surface = Color(0xFF141414);
  static const surfaceElevated = Color(0xFF1C1C1C);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8A8A8A);
  static const textMuted = Color(0xFF3D3D3D);

  // Risk accent — subtle red for danger signal
  static const risk = Color(0xFFD0281E);
  static const riskDim = Color(0xFF3A1210);

  static const divider = Color(0xFF222222);

  // Result levels
  static const levelLow = Color(0xFF2E7D32);     // green
  static const levelMid = Color(0xFFF57F17);     // amber
  static const levelHigh = Color(0xFFD0281E);    // red
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.textPrimary,
        secondary: AppColors.risk,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: 'SF Pro Display',
      textTheme: const TextTheme(
        // Large display text (splash, headers)
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w300,
          color: AppColors.textPrimary,
          height: 1.4,
          letterSpacing: -0.5,
        ),
        // Section titles
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        // Body text
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        // Labels / captions
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
      dividerColor: AppColors.divider,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }
}
