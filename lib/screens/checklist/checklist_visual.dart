import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/questions.dart';
import '../../widgets/waveform_progress.dart';

// ── Ambient background ────────────────────────────────────────

class ChecklistAmbientBackground extends StatelessWidget {
  const ChecklistAmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF0A0A0A)),
        Positioned(
          top: 0,
          right: 0,
          width: MediaQuery.sizeOf(context).width * 0.8,
          height: MediaQuery.sizeOf(context).height * 0.6,
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.5, -0.5),
                colors: [Color(0x1A1D3557), Color(0x00000000)],
              ),
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .custom(
              duration: 5000.ms,
              builder: (_, val, child) =>
                  Opacity(opacity: 0.2 + val * 0.2, child: child),
            ),
      ],
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────

class ChecklistTopBar extends StatelessWidget {
  final int currentIndex;
  final int total;
  final VoidCallback onBack;

  const ChecklistTopBar({
    super.key,
    required this.currentIndex,
    required this.total,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        children: [
          CupertinoButton(
            padding: const EdgeInsets.all(8),
            onPressed: onBack,
            child: const Icon(CupertinoIcons.chevron_left, color: Color(0x99FFFFFF), size: 24),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: WaveformProgress(
                current: currentIndex + 1,
                total: total,
                pastColor: const Color(0xFFEF4444),
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${currentIndex + 1}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0x4DFFFFFF),
                fontFamily: 'Courier',
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated card wrapper (slide left/right) ──────────────────

class ChecklistAnimatedCard extends StatelessWidget {
  final int direction;
  final Widget child;

  const ChecklistAnimatedCard({
    super.key,
    required this.direction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final beginX = direction >= 0 ? 50.0 : -50.0;
    return child
        .animate()
        .fadeIn(duration: 300.ms)
        .moveX(begin: beginX, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}

// ── Question card ─────────────────────────────────────────────

class ChecklistQuestionCard extends StatelessWidget {
  final QuestionItem item;

  const ChecklistQuestionCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category + ID badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x0DFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x1AFFFFFF)),
                ),
                child: Text(
                  item.category,
                  style: const TextStyle(fontSize: 10, color: Color(0x99FFFFFF), letterSpacing: 2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '#${item.id.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 10, color: Color(0x4DFFFFFF), fontFamily: 'Courier'),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.3, end: 0),
          const SizedBox(height: 24),

          // Title
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Color(0xFFFFFFFF),
              height: 1.3,
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 300.ms)
              .slideX(begin: -0.3, end: 0),

          // Subtitle
          if (item.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              item.subtitle!,
              style: const TextStyle(fontSize: 13, color: Color(0xCCFF7D7D), fontWeight: FontWeight.w500),
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
          ],
          const SizedBox(height: 32),

          // Points list
          ...item.points.asMap().entries.map((e) {
            final i = e.key;
            final point = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0x08FFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x0DFFFFFF)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Color(0x80EF4444), blurRadius: 8)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xCCFFFFFF),
                          fontWeight: FontWeight.w300,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 200 + i * 100))
                  .slideY(begin: 0.3, end: 0),
            );
          }),

          // Tip
          if (item.tip != null) ...[
            const Spacer(),
            Row(
              children: [
                const Icon(CupertinoIcons.exclamationmark_circle, size: 16, color: Color(0x66FFFFFF)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.tip!,
                    style: const TextStyle(fontSize: 12, color: Color(0x80FFFFFF)),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 16),
          ] else
            const Spacer(),
        ],
      ),
    );
  }
}
