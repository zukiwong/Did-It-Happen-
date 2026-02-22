import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_theme.dart';
import '../../constants/routes.dart';

/// Post-report screen for "Did they cheat?" entry — information gathering guide.
/// Per UX doc: "进一步确认信息" — common info types, completeness, disclaimers.
/// No advice given. Factual only.
class ResultInfoScreen extends StatelessWidget {
  const ResultInfoScreen({super.key});

  static const _items = [
    _InfoItem(
      title: 'Communication records',
      detail:
          'Message timestamps, frequency changes, deleted conversations.',
    ),
    _InfoItem(
      title: 'Location & schedule',
      detail:
          'Unexplained time gaps, check-in discrepancies, travel records.',
    ),
    _InfoItem(
      title: 'Financial activity',
      detail:
          'Unusual transactions, cash withdrawals, unfamiliar charges.',
    ),
    _InfoItem(
      title: 'Device behavior',
      detail:
          'New apps, changed passwords, notifications hidden from view.',
    ),
    _InfoItem(
      title: 'Social pattern shifts',
      detail:
          'New contacts, changed routines, unexplained social absences.',
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
                'Gather more\ninformation',
                style: Theme.of(context).textTheme.displayLarge,
              ),

              const SizedBox(height: 12),

              Text(
                'Common information types people consider in this situation.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 36),

              ..._items.map((item) => _InfoRow(item: item)),

              const SizedBox(height: 40),

              // Disclaimer — per PRD risk control section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'This content is for reference only and does not constitute professional advice or factual judgment.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem {
  final String title;
  final String detail;
  const _InfoItem({required this.title, required this.detail});
}

class _InfoRow extends StatelessWidget {
  final _InfoItem item;
  const _InfoRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text(item.detail, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          const Divider(color: AppColors.divider, height: 1),
        ],
      ),
    );
  }
}
