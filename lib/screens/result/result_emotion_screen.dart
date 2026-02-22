import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_theme.dart';
import '../../constants/routes.dart';

class ResultEmotionScreen extends StatelessWidget {
  const ResultEmotionScreen({super.key});

  static const _phases = [
    _Phase(label: '矛盾感', detail: '同时想要两件事。这是最常见的情绪状态之一，不是软弱的表现。'),
    _Phase(label: '隔离化', detail: '把生活的各部分分开，以避免冲突。通常会随着时间推移带来越来越大的内在压力。'),
    _Phase(label: '内疚但未行动', detail: '感觉某件事不对，但还无法命名或处理它。'),
    _Phase(label: '合理化', detail: '通过重新诠释行为来减少内心矛盾。这是非常人性化的反应，也是值得审视的信号。'),
    _Phase(label: '寻求清晰', detail: '走到这一步，意味着你内心的某部分想要真正理解正在发生什么。'),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        border: const Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
        leading: GestureDetector(
          onTap: () => context.go(Routes.report),
          child: const Icon(CupertinoIcons.back, color: AppColors.textPrimary, size: 22),
        ),
        middle: const Text(
          '情绪支持',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xxl),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Text('常见心理阶段', style: AppText.title),
                  const SizedBox(height: AppSpacing.xs),
                  const Text('这些是该情境下常见的心理状态。这里没有评判。', style: AppText.bodySecondary),
                  const SizedBox(height: AppSpacing.xl),
                  ..._phases.asMap().entries.map((e) =>
                      _PhaseRow(index: e.key + 1, phase: e.value)),
                ]),
              ),
            ),
          ],
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
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$index',
              style: const TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.risk,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phase.label, style: AppText.body),
                const SizedBox(height: 4),
                Text(phase.detail, style: AppText.bodySecondary),
                const SizedBox(height: AppSpacing.lg),
                Container(height: 0.5, color: AppColors.divider),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
