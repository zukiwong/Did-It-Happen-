import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_theme.dart';
import '../../constants/routes.dart';

/// Post-report screen for "Did I cheat?" entry — emotional support.
/// Per UX doc: "情绪支持" — emotion mapping, self-state recognition, common phases.
/// No judgment, no advice. Reflection only.
class ResultEmotionScreen extends StatelessWidget {
  const ResultEmotionScreen({super.key});

  static const _phases = [
    _Phase(
      label: 'Ambivalence',
      detail:
          'Wanting two things at once. This is one of the most common emotional states — not a sign of weakness.',
    ),
    _Phase(
      label: 'Compartmentalization',
      detail:
          'Separating parts of life to avoid conflict. Often leads to increasing internal pressure over time.',
    ),
    _Phase(
      label: 'Guilt without action',
      detail:
          'Feeling something is wrong, but not yet able to name it or address it.',
    ),
    _Phase(
      label: 'Reframing',
      detail:
          'Rationalizing behavior to reduce dissonance. A very human response — and a signal worth examining.',
    ),
    _Phase(
      label: 'Clarity seeking',
      detail:
          'Arriving here means part of you wants to understand what is actually happening.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: GestureDetector(
          onTap: () => context.go(Routes.report),
          child: const Icon(Icons.arrow_back_ios, size: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emotional\nsupport',
                style: Theme.of(context).textTheme.displayLarge,
              ),

              const SizedBox(height: 12),

              Text(
                'Common psychological states in this situation. There is no judgment here.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 40),

              ..._phases.asMap().entries.map((e) => _PhaseRow(
                    index: e.key + 1,
                    phase: e.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _Phase {
  final String label;
  final String detail;
  const _Phase({required this.label, required this.detail});
}

class _PhaseRow extends StatelessWidget {
  final int index;
  final _Phase phase;

  const _PhaseRow({required this.index, required this.phase});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Index number
          SizedBox(
            width: 28,
            child: Text(
              '$index',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.risk,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phase.label,
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 6),
                Text(phase.detail,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                const Divider(color: AppColors.divider, height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
