import 'package:flutter/cupertino.dart';
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
      final entryType = ref.read(entryTypeProvider);
      final result = ref.read(checklistProvider.notifier).buildResult(entryType);
      ref.read(checkResultProvider.notifier).state = result;
      context.go(Routes.report);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_index];
    final total = _items.length;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        border: const Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
        leading: GestureDetector(
          onTap: () {
            if (_index > 0) {
              setState(() => _index--);
            } else {
              context.go('${Routes.checklist}/phase2');
            }
          },
          child: const Icon(CupertinoIcons.back, color: AppColors.textPrimary, size: 22),
        ),
        middle: const Text(
          '阶段 3 / 3',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w400),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PhaseBar(phase: 3),
              const SizedBox(height: AppSpacing.sm),
              Text('${_index + 1} / $total', style: AppText.captionUppercase),
              const Spacer(flex: 2),
              const Text(
                '价值观',
                style: TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.risk,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(item.question, style: AppText.display),
              if (item.detail != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(item.detail!, style: AppText.bodySecondary),
              ],
              const Spacer(flex: 3),
              _AnswerButton(label: '一致', onTap: () => _answer(false), primary: false),
              const SizedBox(height: AppSpacing.sm),
              _AnswerButton(label: '存在分歧', onTap: () => _answer(true), primary: true),
              const SizedBox(height: AppSpacing.xxl),
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
  const _AnswerButton({required this.label, required this.onTap, required this.primary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: primary ? AppColors.riskDim : AppColors.surfaceElevated,
          border: Border.all(color: primary ? AppColors.risk : AppColors.divider, width: 1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 17,
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
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: Container(
              height: 2,
              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
              color: i < phase ? AppColors.textPrimary : AppColors.divider,
            ),
          );
        }),
      ),
    );
  }
}
