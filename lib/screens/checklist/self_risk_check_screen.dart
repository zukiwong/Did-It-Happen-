import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/questions_self.dart';
import '../../widgets/waveform_progress.dart';

// SelfRiskCheck — 我出轨路径的自查清单
// Each question has a single confirm button that turns green on tap,
// then auto-advances after a short delay.
class SelfRiskCheckScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onComplete;

  const SelfRiskCheckScreen({
    super.key,
    required this.onBack,
    required this.onComplete,
  });

  @override
  State<SelfRiskCheckScreen> createState() => _SelfRiskCheckScreenState();
}

class _SelfRiskCheckScreenState extends State<SelfRiskCheckScreen> {
  int _currentIndex = 0;
  bool _isConfirmed = false;
  int _direction = 0;

  SelfCheckItem get _current => kSelfCheckQuestions[_currentIndex];
  bool get _isLast => _currentIndex == kSelfCheckQuestions.length - 1;

  void _handleConfirm() {
    if (_isConfirmed) return;
    setState(() => _isConfirmed = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      if (_isLast) {
        widget.onComplete();
      } else {
        setState(() {
          _direction = 1;
          _isConfirmed = false;
          _currentIndex++;
        });
      }
    });
  }

  void _handlePrev() {
    if (_currentIndex > 0) {
      setState(() {
        _direction = -1;
        _isConfirmed = true;
        _currentIndex--;
      });
    } else {
      widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF050505),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _EmeraldAmbient(),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                _TopBar(
                  currentIndex: _currentIndex,
                  total: kSelfCheckQuestions.length,
                  onBack: _handlePrev,
                ),

                // Question card
                Expanded(
                  child: _AnimatedCard(
                    key: ValueKey(_currentIndex),
                    direction: _direction,
                    child: _SelfQuestionCard(item: _current),
                  ),
                ),

                // Confirm button
                _ConfirmButton(
                  isConfirmed: _isConfirmed,
                  isLast: _isLast,
                  onTap: _handleConfirm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Emerald ambient glow (top-right) ─────────────────────────

class _EmeraldAmbient extends StatelessWidget {
  const _EmeraldAmbient();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Positioned(
      top: 0,
      right: 0,
      width: size.width * 0.8,
      height: size.height * 0.6,
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.5, -0.5),
            colors: [Color(0x1A064E3B), Color(0x00000000)],
          ),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .custom(
            duration: 5000.ms,
            builder: (_, val, child) =>
                Opacity(opacity: 0.1 + val * 0.2, child: child),
          ),
    );
  }
}

// ── Top bar (reuses same structure as TraceChecklist) ─────────

class _TopBar extends StatelessWidget {
  final int currentIndex;
  final int total;
  final VoidCallback onBack;

  const _TopBar({
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
            child: const Icon(
              CupertinoIcons.chevron_left,
              color: Color(0x99FFFFFF),
              size: 24,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: WaveformProgress(
                current: currentIndex + 1,
                total: total,
                pastColor: const Color(0xFF10B981),
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

class _AnimatedCard extends StatelessWidget {
  final int direction;
  final Widget child;
  const _AnimatedCard({super.key, required this.direction, required this.child});

  @override
  Widget build(BuildContext context) {
    final beginX = direction >= 0 ? 50.0 : -50.0;
    return child
        .animate()
        .fadeIn(duration: 300.ms)
        .moveX(begin: beginX, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}

// ── Self-check question card ──────────────────────────────────

class _SelfQuestionCard extends StatelessWidget {
  final SelfCheckItem item;
  const _SelfQuestionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge + signal number
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x0DFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x1AFFFFFF)),
                ),
                child: Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0x99FFFFFF),
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '信号 #${item.id.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0x4DFFFFFF),
                  fontFamily: 'Courier',
                ),
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
          const SizedBox(height: 32),

          // Points label
          const Text(
            '核查要点',
            style: TextStyle(
              fontSize: 10,
              color: Color(0x33FFFFFF),
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms),
          const SizedBox(height: 16),

          // Points
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
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x8010B981),
                              blurRadius: 8,
                            )
                          ],
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x0D10B981),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x1A10B981)),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_circle,
                    size: 16,
                    color: Color(0x6610B981),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.tip!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0x9910B981),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms),
            const SizedBox(height: 16),
          ] else
            const Spacer(),
        ],
      ),
    );
  }
}

// ── Confirm button ────────────────────────────────────────────

class _ConfirmButton extends StatelessWidget {
  final bool isConfirmed;
  final bool isLast;
  final VoidCallback onTap;

  const _ConfirmButton({
    required this.isConfirmed,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFF000000), Color(0x00050505)],
        ),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: 80,
          decoration: BoxDecoration(
            color: isConfirmed
                ? const Color(0x3310B981)
                : const Color(0x08FFFFFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isConfirmed
                  ? const Color(0x8010B981)
                  : const Color(0x1AFFFFFF),
            ),
            boxShadow: isConfirmed
                ? const [
                    BoxShadow(
                      color: Color(0x3310B981),
                      blurRadius: 30,
                    )
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '核查状态确认',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                        color: const Color(0xFFFFFFFF)
                            .withValues(alpha: isConfirmed ? 0.6 : 0.4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isConfirmed
                          ? (isLast ? '检查已闭环' : '确认完毕 · 跳转下一项')
                          : '待执行操作',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isConfirmed
                            ? const Color(0xFF34D399)
                            : const Color(0x66FFFFFF),
                      ),
                    ),
                  ],
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isConfirmed
                        ? const Color(0xFF10B981)
                        : const Color(0x0DFFFFFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isConfirmed
                          ? const Color(0xFF34D399)
                          : const Color(0x1AFFFFFF),
                    ),
                  ),
                  child: Icon(
                    isConfirmed
                        ? CupertinoIcons.checkmark_circle_fill
                        : CupertinoIcons.checkmark,
                    size: 18,
                    color: isConfirmed
                        ? const Color(0xFF000000)
                        : const Color(0x1AFFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
