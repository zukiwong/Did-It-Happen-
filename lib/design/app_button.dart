import 'package:flutter/cupertino.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text.dart';

/// Primary full-width CTA button (white background, black text).
/// Matches the pattern seen in ArchiveAccess "解锁并进入" and
/// TraceReport save buttons.
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = AppSize.buttonPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1AFFFFFF),
              blurRadius: 30,
              offset: Offset(0, 10),
            )
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: AppText.labelMed.copyWith(color: const Color(0xFF000000)),
          ),
        ),
      ),
    );
  }
}

/// Ghost button — translucent border, used for secondary actions.
/// Matches "再检查一次", "退出", and the checklist next button.
class AppGhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final IconData? icon;

  const AppGhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = AppSize.buttonSecondary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0x05FFFFFF),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: const Color(0x0DFFFFFF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: AppColors.textDim),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(label, style: AppText.labelMed.copyWith(color: AppColors.textDim)),
          ],
        ),
      ),
    );
  }
}

/// Back button — chevron + optional label, used in top-left of most screens.
class AppBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color color;

  const AppBackButton({
    super.key,
    required this.onPressed,
    this.label = '返回',
    this.color = const Color(0x4DFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.chevron_left, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon-only circular button (44×44 tap target).
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double iconSize;
  final Color color;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconSize = 20,
    this.color = const Color(0x4DFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(AppSize.iconButton, AppSize.iconButton),
      onPressed: onPressed,
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}
