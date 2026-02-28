import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ReportUnlockState { input, unlocked }

// ── Secret key / save section ─────────────────────────────────

class ReportKeySection extends StatelessWidget {
  final ReportUnlockState unlockState;
  final TextEditingController controller;
  final VoidCallback onConfirm;
  final String? errorText;

  const ReportKeySection({
    super.key,
    required this.unlockState,
    required this.controller,
    required this.onConfirm,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    if (unlockState == ReportUnlockState.unlocked) {
      return const ReportLockedSuccess();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0x0DFFFFFF),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: const Icon(CupertinoIcons.lock, size: 10, color: Color(0x66FFFFFF)),
            ),
            const SizedBox(width: 8),
            const Text(
              '设置档案访问密钥',
              style: TextStyle(fontSize: 12, color: Color(0x66FFFFFF), fontWeight: FontWeight.w600, letterSpacing: 3),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          controller: controller,
          obscureText: true,
          placeholder: '输入访问密钥以锁定档案',
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 14,
            fontFamily: 'Courier',
            letterSpacing: 8,
          ),
          placeholderStyle: const TextStyle(
            color: Color(0x33FFFFFF),
            fontSize: 14,
            fontFamily: 'Courier',
            letterSpacing: 1,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0x08FFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1AFFFFFF)),
          ),
          suffix: const Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(CupertinoIcons.doc_on_doc, size: 16, color: Color(0x1AFFFFFF)),
          ),
        ),
        const SizedBox(height: 16),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onConfirm,
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color(0x1AFFFFFF), blurRadius: 30, offset: Offset(0, 10)),
              ],
            ),
            child: const Center(
              child: Text(
                '加密并锁定档案',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF000000), letterSpacing: 4),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 12),
          Text(
            errorText!,
            style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ── Locked success ────────────────────────────────────────────

class ReportLockedSuccess extends StatelessWidget {
  const ReportLockedSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0x0D10B981),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x3310B981)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0x1A10B981),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x3310B981)),
                    ),
                    child: const Icon(CupertinoIcons.checkmark_circle_fill, size: 24, color: Color(0xFF34D399)),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '观察档案已安全锁定',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFD1FAE5)),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '该报告已完成本地加密，只有持有访问密钥的人员可再次开启。',
                      style: TextStyle(fontSize: 11, color: Color(0x9934D399), fontWeight: FontWeight.w300, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 1, child: ColoredBox(color: Color(0x1A10B981))),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(CupertinoIcons.lock, size: 12, color: Color(0x6610B981)),
                  SizedBox(width: 8),
                  Text(
                    'Hash: 8FA...D21',
                    style: TextStyle(fontSize: 9, color: Color(0x9910B981), fontFamily: 'Courier', letterSpacing: 4),
                  ),
                ],
              ),
              Row(
                children: List.generate(4, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                    )
                        .animate(delay: Duration(milliseconds: i * 200), onPlay: (c) => c.repeat(reverse: true))
                        .custom(
                          duration: 1200.ms,
                          builder: (_, val, child) => Opacity(opacity: 0.2 + val * 0.8, child: child),
                        ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.98, 0.98));
  }
}
