import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_theme.dart';
import '../../constants/routes.dart';
import '../../providers/checklist_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _start(BuildContext context, WidgetRef ref, String type) {
    ref.read(entryTypeProvider.notifier).state = type;
    ref.read(checklistProvider.notifier).reset();
    context.go(Routes.checklist);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              const Text('你想确认\n什么？', style: AppText.display),
              const SizedBox(height: AppSpacing.sm),
              const Text('选择一项，检测内容将根据你的选择调整。', style: AppText.bodySecondary),
              const Spacer(),
              _EntryCard(
                label: 'TA出轨了吗',
                sublabel: '检测伴侣行为中的异常信号',
                onTap: () => _start(context, ref, 'partner'),
              ),
              const SizedBox(height: AppSpacing.md),
              _EntryCard(
                label: '我出轨了吗',
                sublabel: '审视自己的行为模式与选择',
                onTap: () => _start(context, ref, 'self'),
                dimmed: true,
              ),
              const SizedBox(height: AppSpacing.xxl),
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
        decoration: BoxDecoration(
          color: dimmed ? AppColors.surfaceElevated : AppColors.surface,
          border: Border.all(
            color: dimmed ? AppColors.divider : AppColors.textMuted,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppText.title.copyWith(
                color: dimmed ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(sublabel, style: AppText.bodySecondary),
          ],
        ),
      ),
    );
  }
}
