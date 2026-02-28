import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ── Background ────────────────────────────────────────────────

class ReportBackground extends StatelessWidget {
  const ReportBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Color(0xFF050505)),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 1,
          child: ColoredBox(color: Color(0x0DFFFFFF)),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────

class ReportHeader extends StatelessWidget {
  final VoidCallback onBack;
  final bool isSaved;

  const ReportHeader({super.key, required this.onBack, required this.isSaved});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onBack,
                child: const Icon(CupertinoIcons.chevron_left,
                    size: 24, color: Color(0x99FFFFFF)),
              ),
              const SizedBox(height: 12),
              const Text(
                '痕迹观察报告',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Color(0xE5FFFFFF)),
              ),
            ],
          ),
        ),
        ReportStatusBadge(active: isSaved),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.3, end: 0);
  }
}

class ReportStatusBadge extends StatelessWidget {
  final bool active;

  const ReportStatusBadge({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x08FFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (active)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .scale(begin: const Offset(1, 1), end: const Offset(1.6, 1.6), duration: 1000.ms)
                    .fadeOut(duration: 1000.ms),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            active ? '档案已激活' : '档案已锁定',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 3, color: Color(0xE534D399)),
          ),
        ],
      ),
    );
  }
}

// ── Cinematic visual ──────────────────────────────────────────

class ReportCinematicVisual extends StatelessWidget {
  const ReportCinematicVisual({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 224,
      color: const Color(0xFF030303),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Center(child: _ConnectionLine()),
          Positioned(
            left: 40,
            top: 0,
            bottom: 0,
            child: Center(child: const _OrbitingSphere(reverse: false))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: -25, end: 25, duration: 10000.ms, curve: Curves.easeInOut),
          ),
          Center(child: const _PulsePoint()),
          Positioned(
            right: 40,
            top: 0,
            bottom: 0,
            child: Center(child: const _OrbitingSphere(reverse: true))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 25, end: -25, duration: 10000.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }
}

class _ConnectionLine extends StatelessWidget {
  const _ConnectionLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: const Color(0x1AFFFFFF)),
          ...List.generate(3, (i) {
            return Container(
              width: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x00FFFFFF), Color(0x4DFFFFFF), Color(0x00FFFFFF)],
                ),
              ),
            )
                .animate(delay: Duration(seconds: i), onPlay: (c) => c.repeat())
                .moveX(begin: -200, end: 400, duration: 3000.ms, curve: Curves.linear);
          }),
        ],
      ),
    );
  }
}

class _OrbitingSphere extends StatelessWidget {
  final bool reverse;
  const _OrbitingSphere({required this.reverse});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(color: Color(0x1AFFFFFF), shape: BoxShape.circle),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 4000.ms)
            .custom(
              duration: 4000.ms,
              builder: (_, val, child) => Opacity(opacity: 0.05 + val * 0.15, child: child),
            ),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x33FFFFFF), width: 1),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .rotate(begin: 0, end: reverse ? -1 : 1, duration: 10000.ms, curve: Curves.linear),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x4DFFFFFF)),
            color: const Color(0x0DFFFFFF),
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Color(reverse ? 0x66FFFFFF : 0xFFFFFFFF),
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Color(0xCCFFFFFF), blurRadius: 12)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PulsePoint extends StatelessWidget {
  const _PulsePoint();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ...List.generate(2, (i) {
          return Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
          )
              .animate(delay: Duration(seconds: i), onPlay: (c) => c.repeat())
              .scale(begin: const Offset(1, 1), end: const Offset(3, 3), duration: 2000.ms)
              .fadeOut(duration: 2000.ms);
        }),
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 15)],
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(1, 1), end: const Offset(1.4, 1.4), duration: 2000.ms)
            .custom(
              duration: 2000.ms,
              builder: (_, val, child) => Opacity(opacity: 0.3 + val * 0.7, child: child),
            ),
      ],
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────

class ReportStatsRow extends StatelessWidget {
  /// Number of flagged items out of total questions.
  final int flaggedCount;
  final int totalCount;

  const ReportStatsRow({
    super.key,
    required this.flaggedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    // Signal score: percentage of questions marked normal (no anomaly)
    final normalCount = totalCount - flaggedCount;
    final scorePercent = totalCount == 0 ? 0.0 : normalCount / totalCount * 100;
    final scoreStr = '${scorePercent.toStringAsFixed(1)}%';

    // Status text based on flagged ratio
    final String statusText;
    final Color statusColor;
    if (flaggedCount == 0) {
      statusText = '未发现明显异常';
      statusColor = const Color(0xCC34D399);
    } else if (flaggedCount <= totalCount * 0.3) {
      statusText = '存在少量异常迹象';
      statusColor = const Color(0xCCFBBF24);
    } else {
      statusText = '存在明显异常迹象';
      statusColor = const Color(0xCCF87171);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(children: [
          const Text('关系信号', style: TextStyle(fontSize: 11, color: Color(0x66FFFFFF), letterSpacing: 2)),
          const SizedBox(height: 4),
          Text(scoreStr, style: const TextStyle(fontSize: 14, color: Color(0xCC34D399), fontFamily: 'Courier')),
        ]),
        const SizedBox(width: 24),
        const SizedBox(width: 1, height: 24, child: ColoredBox(color: Color(0x0DFFFFFF))),
        const SizedBox(width: 24),
        Column(children: [
          const Text('观察状态', style: TextStyle(fontSize: 11, color: Color(0x66FFFFFF), letterSpacing: 2)),
          const SizedBox(height: 4),
          Text(statusText, style: TextStyle(fontSize: 14, color: statusColor)),
        ]),
      ],
    );
  }
}

// ── Info card ─────────────────────────────────────────────────

class ReportInfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final String emptyHint;
  final int delay;

  const ReportInfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    this.emptyHint = '暂无异常记录',
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x05FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0DFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0x08FFFFFF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x0DFFFFFF)),
                ),
                child: Icon(icon, size: 12, color: const Color(0x66FFFFFF)),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Color(0x66FFFFFF), fontWeight: FontWeight.w600, letterSpacing: 3),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(
              emptyHint,
              style: const TextStyle(fontSize: 13, color: Color(0x33FFFFFF), fontWeight: FontWeight.w300, height: 1.6),
            )
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 13, color: Color(0xB3FFFFFF), fontWeight: FontWeight.w300, height: 1.6),
                  ),
                )),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }
}
