import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_theme.dart';
import '../../constants/checklist_data.dart';
import '../../constants/routes.dart';
import '../../models/checklist_item.dart';
import '../../providers/checklist_provider.dart';

class Phase3Screen extends ConsumerStatefulWidget {
  const Phase3Screen({super.key});

  @override
  ConsumerState<Phase3Screen> createState() => _Phase3ScreenState();
}

class _Phase3ScreenState extends ConsumerState<Phase3Screen> {
  int _index = 0;

  List<ChecklistItem> get _items =>
      kChecklistItems.where((i) => i.phase == 3).toList();

  void _answer(bool flagged) {
    final item = _items[_index];
    ref.read(checklistProvider.notifier).toggle(item.id, flagged);

    if (_index < _items.length - 1) {
      setState(() => _index++);
    } else {
      // All done — compute result and go to generating animation
      final entryType = ref.read(entryTypeProvider);
      final result =
          ref.read(checklistProvider.notifier).buildResult(entryType);
      ref.read(checkResultProvider.notifier).state = result;
      context.go(Routes.report);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_index];
    final total = _items.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: GestureDetector(
          onTap: () {
            if (_index > 0) {
              setState(() => _index--);
            } else {
              context.go('${Routes.checklist}/phase2');
            }
          },
          child: const Icon(Icons.arrow_back_ios, size: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phase 3 of 3
              _PhaseBar(phase: 3),
              const SizedBox(height: 8),

              Text(
                '${_index + 1} / $total',
                style: Theme.of(context).textTheme.labelSmall,
              ),

              const Spacer(flex: 2),

              // Category label — cognitive gap framing
              Text(
                'Values & Perception',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.risk,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 16),

              Text(
                item.question,
                style: Theme.of(context).textTheme.displayLarge,
              ),

              if (item.detail != null) ...[
                const SizedBox(height: 20),
                Text(
                  item.detail!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],

              const Spacer(flex: 3),

              _AnswerButton(
                label: 'Aligned',
                onTap: () => _answer(false),
                primary: false,
              ),
              const SizedBox(height: 12),
              _AnswerButton(
                label: 'There is a gap',
                onTap: () => _answer(true),
                primary: true,
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary;

  const _AnswerButton({
    required this.label,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: primary ? AppColors.riskDim : AppColors.surfaceElevated,
          border: Border.all(
            color: primary ? AppColors.risk : AppColors.divider,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: primary ? AppColors.risk : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PhaseBar extends StatelessWidget {
  final int phase;
  const _PhaseBar({required this.phase});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
