import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_theme.dart';
import '../../constants/checklist_data.dart';
import '../../constants/routes.dart';
import '../../models/checklist_item.dart';
import '../../providers/checklist_provider.dart';

class ChecklistScreen extends ConsumerWidget {
  const ChecklistScreen({super.key});

  // Phase 1 items only
  List<ChecklistItem> get _phase1 =>
      kChecklistItems.where((i) => i.phase == 1).toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(checklistProvider);
    final items = _phase1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: GestureDetector(
          onTap: () => context.go(Routes.home),
          child: const Icon(Icons.arrow_back_ios, size: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            _ProgressBar(phase: 1),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                'Relationship Signals',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Text(
                'Select all that have changed noticeably.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            // Question list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(
                  color: AppColors.divider,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final flagged = answers[item.id] ?? false;
                  return _CheckRow(
                    item: item,
                    flagged: flagged,
                    onToggle: (val) =>
                        ref.read(checklistProvider.notifier).toggle(item.id, val),
                  );
                },
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    // Save phase1 answers as-is for unanswered (default false)
                    context.go('${Routes.checklist}/phase2');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final ChecklistItem item;
  final bool flagged;
  final ValueChanged<bool> onToggle;

  const _CheckRow({
    required this.item,
    required this.flagged,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!flagged),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.question,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: flagged
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
              ),
            ),
            const SizedBox(width: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: flagged ? AppColors.risk : Colors.transparent,
                border: Border.all(
                  color:
                      flagged ? AppColors.risk : AppColors.textMuted,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: flagged
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int phase;
  const _ProgressBar({required this.phase});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        children: List.generate(3, (i) {
          final active = i < phase;
          return Expanded(
            child: Container(
              height: 2,
              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
              color: active ? AppColors.textPrimary : AppColors.divider,
            ),
          );
        }),
      ),
    );
  }
}
