import 'package:flutter/cupertino.dart';

/// App color palette — dark, cold, high-contrast
class AppColors {
  static const background = Color(0xFF0A0A0A);
  static const surface = Color(0xFF141414);
  static const surfaceElevated = Color(0xFF1C1C1C);

  static const textPrimary = CupertinoColors.white;
  static const textSecondary = Color(0xFF8A8A8A);
  static const textMuted = Color(0xFF3D3D3D);

  // Risk accent — subtle red for danger signal
  static const risk = Color(0xFFD0281E);
  static const riskDim = Color(0xFF3A1210);

  static const divider = Color(0xFF222222);

  // Result levels
  static const levelLow = Color(0xFF2E7D32);
  static const levelMid = Color(0xFFF57F17);
  static const levelHigh = Color(0xFFD0281E);
}

/// iOS-rhythm spacing — 8/12/16/24
class AppSpacing {
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

/// Consistent corner radii
class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
}

/// Text styles — SF Pro, iOS rhythm
class AppText {
  // Large display (splash, report title)
  static const display = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 28,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: -0.5,
  );

  // Section / screen title
  static const title = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  // Body
  static const body = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const bodySecondary = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Caption / label
  static const caption = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    letterSpacing: 0.3,
  );

  static const captionUppercase = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 1.2,
  );
}
