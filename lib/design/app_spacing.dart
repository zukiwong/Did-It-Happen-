/// Spacing tokens — all multiples of 8.
abstract final class AppSpacing {
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 16;
  static const double lg   = 24;
  static const double xl   = 32;
  static const double xl2  = 40;
  static const double xl3  = 48;
  static const double xl4  = 64;

  /// Standard horizontal page padding
  static const double pagePadH = 24;

  /// Standard vertical page top padding (below safe area)
  static const double pagePadTop = 20;
}

/// Border radius tokens
abstract final class AppRadius {
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 24;
  static const double xl2 = 32;
  static const double full = 999;
}

/// Standard interactive element heights
abstract final class AppSize {
  static const double buttonPrimary   = 60;
  static const double buttonSecondary = 56;
  static const double buttonLarge     = 64;
  static const double iconButton      = 44;
}
