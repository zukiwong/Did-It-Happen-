import 'package:flutter/cupertino.dart';
import 'app_colors.dart';

/// Typography scale derived from Figma design.
///
/// Scale (px):  9 → 10 → 12 → 14 → 16 → 20 → 24 → 32
/// Weights:     light(300) for titles, medium(500) for emphasis,
///              bold(700) for labels/buttons
abstract final class AppText {
  // ── Display ───────────────────────────────────────────────────
  /// 32px light — splash / sanctuary hero title
  static const display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // ── Titles ────────────────────────────────────────────────────
  /// 24px light — page heading (TA出轨了, 历史观察报告, ...)
  static const titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w300,
    color: AppColors.textMed,
  );

  /// 20px light — section heading
  static const titleMed = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: AppColors.textMed,
  );

  // ── Body ──────────────────────────────────────────────────────
  /// 16px light — primary body copy (self reflection paragraphs)
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w300,
    color: AppColors.textSecondary,
    height: 1.8,
  );

  /// 14px light — secondary body (card descriptions, chat bubbles)
  static const bodyMed = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  /// 13px light — compact body (evidence points, list items)
  static const bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w300,
    color: AppColors.textMuted,
    height: 1.6,
  );

  // ── Labels ────────────────────────────────────────────────────
  /// 12px medium — button labels, chip text
  static const labelLarge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMed,
    letterSpacing: 1.0,
  );

  /// 11px bold — action button labels (uppercase, tracked)
  static const labelMed = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 4.0,
  );

  /// 10px bold — section meta labels (CURRENT POSITION style)
  static const labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textFaint,
    letterSpacing: 6.0,
  );

  // ── Captions ──────────────────────────────────────────────────
  /// 9px bold — timestamps, IDs, minimal metadata
  static const caption = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: AppColors.textGhost,
    letterSpacing: 4.0,
  );

  /// Monospace variant for technical values (hashes, timestamps)
  static const mono = TextStyle(
    fontSize: 10,
    fontFamily: 'Courier',
    color: AppColors.textDim,
    letterSpacing: 2.0,
  );
}
