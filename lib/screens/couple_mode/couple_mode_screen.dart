import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_theme.dart';
import '../../constants/routes.dart';

class CoupleModeScreen extends StatelessWidget {
  const CoupleModeScreen({super.key});

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
          '情侣共同检测',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              const Text('情侣检测', style: AppText.display),
              const SizedBox(height: AppSpacing.sm),
              const Text('双方独立完成清单，结果并排对比。', style: AppText.bodySecondary),
              const SizedBox(height: AppSpacing.xxl),
              const _Step(number: '01', label: '创建共享检测'),
              const _Step(number: '02', label: '将邀请码发给你的伴侣'),
              const _Step(number: '03', label: '双方各自独立填写'),
              const _Step(number: '04', label: '查看双方结果对比'),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // TODO: Supabase session creation
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '开始情侣检测',
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.background,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String label;
  const _Step({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.risk,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: AppText.body)),
        ],
      ),
    );
  }
}
