import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_theme.dart';
import '../../constants/checklist_data.dart';
import '../../constants/routes.dart';
import '../../models/checklist_item.dart';
import '../../providers/checklist_provider.dart';

class ChecklistScreen extends ConsumerWidget {
  const ChecklistScreen({super.key});

  List<ChecklistItem> get _phase1 =>
      kChecklistItems.where((i) => i.phase == 1).toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(checklistProvider);
    final items = _phase1;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
        middle: Text(
          '阶段 1 / 3',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w400),
        ),
        automaticallyImplyLeading: false,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PhaseBar(phase: 1),
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs),
              child: Text('关系信号', style: AppText.title),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: Text('选择所有明显发生变化的项目。', style: AppText.bodySecondary),
            ),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: items.length,
                separatorBuilder: (_, _) => Container(height: 0.5, color: AppColors.divider),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
              child: GestureDetector(
                onTap: () => context.go('${Routes.checklist}/phase2'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '继续',
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.background,
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
  const _CheckRow({required this.item, required this.flagged, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!flagged),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.question,
                style: AppText.body.copyWith(
                  color: flagged ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: flagged ? AppColors.risk : CupertinoColors.transparent,
                border: Border.all(
                  color: flagged ? AppColors.risk : AppColors.textMuted,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: flagged
                  ? const Icon(CupertinoIcons.checkmark, size: 13, color: CupertinoColors.white)
                  : null,
            ),
          ],
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
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
