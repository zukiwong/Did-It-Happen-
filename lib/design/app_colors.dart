import 'package:flutter/cupertino.dart';

/// Semantic color tokens derived from Figma design.
/// All colors are white-on-dark with opacity variants for hierarchy.
abstract final class AppColors {
  // ── Text hierarchy ────────────────────────────────────────────
  static const textPrimary   = Color(0xFFFFFFFF); // 100%
  static const textHigh      = Color(0xE5FFFFFF); // 90%
  static const textMed       = Color(0xCCFFFFFF); // 80%
  static const textSecondary = Color(0x99FFFFFF); // 60%
  static const textTertiary  = Color(0x80FFFFFF); // 50%
  static const textMuted     = Color(0x66FFFFFF); // 40%
  static const textDim       = Color(0x4DFFFFFF); // 30%
  static const textFaint     = Color(0x33FFFFFF); // 20%
  static const textGhost     = Color(0x1AFFFFFF); // 10%
  static const textInvisible = Color(0x0DFFFFFF); // 5%

  // ── Status ────────────────────────────────────────────────────
  static const statusError   = Color(0xFFEF4444); // anomaly / error
  static const statusSuccess = Color(0xFF34D399); // confirmed / unlocked
  static const statusSuccessBg = Color(0x1A10B981);

  // ── Surfaces ──────────────────────────────────────────────────
  static const surfaceSubtle  = Color(0x0AFFFFFF); // 4%
  static const surfaceLight   = Color(0x1AFFFFFF); // 10%
  static const surfaceMed     = Color(0x33FFFFFF); // 20%

  // ── Page backgrounds ──────────────────────────────────────────
  static const bgPrimary = Color(0xFF0A0A0A);
  static const bgDark    = Color(0xFF050505);
  static const bgDeep    = Color(0xFF020203);
  static const bgCard    = Color(0xFF0E0E10);
}
