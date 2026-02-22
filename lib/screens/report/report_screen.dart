import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
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
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.textPrimary)),
      );
    }

    final screenshotController = ScreenshotController();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back nav
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: GestureDetector(
                onTap: () => context.go(Routes.home),
                child: const Icon(Icons.arrow_back_ios,
                    size: 18, color: AppColors.textPrimary),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title — per UX doc: "关系检测报告"
                    Text(
                      'Relationship\nDetection Report',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),

                    const SizedBox(height: 32),

                    // Risk level indicator
                    _RiskBadge(level: result.riskLevel, label: result.riskLabel),

                    const SizedBox(height: 8),

                    Text(
                      '${result.flaggedCount} anomalous signals out of ${result.totalCount} items',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 32),

                    // Flagged items
                    if (result.flagged.isNotEmpty) ...[
                      _SectionLabel(label: 'Anomalous signals'),
                      const SizedBox(height: 12),
                      ...result.flagged.map((item) => _ItemRow(
                            text: item.question,
                            flagged: true,
                          )),
                      const SizedBox(height: 28),
                    ],

                    // Passed items
                    if (result.passed.isNotEmpty) ...[
                      _SectionLabel(label: 'No anomaly detected'),
                      const SizedBox(height: 12),
                      ...result.passed.map((item) => _ItemRow(
                            text: item.question,
                            flagged: false,
                          )),
                    ],

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),

            // Bottom actions — per UX doc: next step entry + share
            _BottomActions(result: result, screenshotController: screenshotController),
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
      case RiskLevel.low:
        return AppColors.levelLow;
      case RiskLevel.mid:
        return AppColors.levelMid;
      case RiskLevel.high:
        return AppColors.levelHigh;
    }
  }

  String get _dot {
    switch (level) {
      case RiskLevel.low:
        return '●';
      case RiskLevel.mid:
        return '●';
      case RiskLevel.high:
        return '●';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(_dot, style: TextStyle(color: _color, fontSize: 14)),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
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
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.4,
          ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final String text;
  final bool flagged;

  const _ItemRow({required this.text, required this.flagged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            flagged ? '×' : '✓',
            style: TextStyle(
              fontSize: 14,
              color: flagged ? AppColors.risk : AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: flagged
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
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
  final ScreenshotController screenshotController;

  const _BottomActions({
    required this.result,
    required this.screenshotController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Per UX doc: different next-step based on entry type
    final isPartner = result.entryType == 'partner';
    final nextLabel =
        isPartner ? 'Gather more information' : 'Emotional support';
    final nextRoute = isPartner ? Routes.resultInfo : Routes.resultEmotion;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        children: [
          // Primary next step
          GestureDetector(
            onTap: () => context.go(nextRoute),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                nextLabel,
                style: const TextStyle(
                  color: AppColors.background,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Share button
          GestureDetector(
            onTap: () => context.go('${Routes.resultInfo}/share'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Share result',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
