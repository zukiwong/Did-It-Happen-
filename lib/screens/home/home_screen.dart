import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_theme.dart';
import '../../constants/routes.dart';
import '../../providers/checklist_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _startDetection(BuildContext context, WidgetRef ref, String type) {
    ref.read(entryTypeProvider.notifier).state = type;
    ref.read(checklistProvider.notifier).reset();
    context.go(Routes.checklist);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),

              Text(
                'What do you want\nto find out?',
                style: Theme.of(context).textTheme.displayLarge,
              ),

              const SizedBox(height: 12),

              Text(
                'Choose one. The detection is tailored to your selection.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const Spacer(),

              // Partner entry
              _EntryCard(
                label: 'Did they cheat?',
                sublabel: 'Detect signals in your partner\'s behavior',
                onTap: () => _startDetection(context, ref, 'partner'),
              ),

              const SizedBox(height: 16),

              // Self entry
              _EntryCard(
                label: 'Did I cheat?',
                sublabel: 'Reflect on your own patterns and choices',
                onTap: () => _startDetection(context, ref, 'self'),
                dimmed: true,
              ),

              const SizedBox(height: 56),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final VoidCallback onTap;
  final bool dimmed;

  const _EntryCard({
    required this.label,
    required this.sublabel,
    required this.onTap,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: dimmed ? AppColors.surfaceElevated : AppColors.surface,
          border: Border.all(
            color: dimmed ? AppColors.divider : AppColors.textMuted,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: dimmed
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              sublabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
