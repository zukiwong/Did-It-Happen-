import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_theme.dart';
import '../../constants/routes.dart';

class ResultInfoScreen extends StatelessWidget {
  const ResultInfoScreen({super.key});

  static const _items = [
    _InfoItem(title: '通讯记录', detail: '消息时间戳、频率变化、已删除的对话。'),
    _InfoItem(title: '行程与日程', detail: '无法解释的时间段、打卡记录不一致、出行记录。'),
    _InfoItem(title: '资金动向', detail: '异常消费、现金提取、陌生账单。'),
    _InfoItem(title: '设备行为', detail: '新应用、更换密码、屏蔽通知。'),
    _InfoItem(title: '社交模式变化', detail: '新联系人、作息改变、无故缺席。'),
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
          '进一步确认信息',
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
                  const Text('常见信息类型', style: AppText.title),
                  const SizedBox(height: AppSpacing.xs),
                  const Text('以下为该情况下人们通常会考虑整理的信息类型。', style: AppText.bodySecondary),
                  const SizedBox(height: AppSpacing.xl),
                  ..._items.map((item) => _InfoRow(item: item)),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Text(
                      '本内容仅供参考，不构成专业意见或事实判断。',
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
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
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: AppText.body),
          const SizedBox(height: 4),
          Text(item.detail, style: AppText.bodySecondary),
          const SizedBox(height: AppSpacing.lg),
          Container(height: 0.5, color: AppColors.divider),
        ],
      ),
    );
  }
}
