import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_theme.dart';
import '../../constants/routes.dart';
import '../../models/check_result.dart';
import '../../providers/checklist_provider.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(checkResultProvider);

    if (result == null) {
      return const CupertinoPageScaffold(
        backgroundColor: AppColors.background,
        child: Center(child: CupertinoActivityIndicator(color: AppColors.textPrimary)),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        border: const Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
        leading: GestureDetector(
          onTap: () => context.go(Routes.home),
          child: const Icon(CupertinoIcons.back, color: AppColors.textPrimary, size: 22),
        ),
        middle: const Text(
          '关系检测报告',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _RiskBadge(level: result.riskLevel, label: result.riskLabel),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '共 ${result.totalCount} 项，检测到 ${result.flaggedCount} 项异常信号',
                          style: AppText.bodySecondary,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        if (result.flagged.isNotEmpty) ...[
                          const _SectionLabel(label: '异常信号'),
                          const SizedBox(height: AppSpacing.sm),
                          ...result.flagged.map((item) =>
                              _ItemRow(text: item.question, flagged: true)),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        if (result.passed.isNotEmpty) ...[
                          const _SectionLabel(label: '未发现异常'),
                          const SizedBox(height: AppSpacing.sm),
                          ...result.passed.map((item) =>
                              _ItemRow(text: item.question, flagged: false)),
                        ],
                        const SizedBox(height: AppSpacing.xxl),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            _BottomActions(result: result),
          ],
        ),
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final RiskLevel level;
  final String label;
  const _RiskBadge({required this.level, required this.label});

  Color get _color {
    switch (level) {
      case RiskLevel.low: return AppColors.levelLow;
      case RiskLevel.mid: return AppColors.levelMid;
      case RiskLevel.high: return AppColors.levelHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: _color,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(), style: AppText.captionUppercase);
  }
}

class _ItemRow extends StatelessWidget {
  final String text;
  final bool flagged;
  const _ItemRow({required this.text, required this.flagged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            flagged ? '×' : '✓',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: flagged ? AppColors.risk : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppText.bodySecondary.copyWith(
                color: flagged ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends ConsumerWidget {
  final CheckResult result;
  const _BottomActions({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPartner = result.entryType == 'partner';
    final nextLabel = isPartner ? '进一步确认信息' : '情绪支持';
    final nextRoute = isPartner ? Routes.resultInfo : Routes.resultEmotion;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => context.go(nextRoute),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              alignment: Alignment.center,
              child: Text(
                nextLabel,
                style: const TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.background,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              alignment: Alignment.center,
              child: const Text(
                '分享结果',
                style: TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
