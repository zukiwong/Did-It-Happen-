import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

// SelfReflectionSpace — 我出轨路径的结果页
// Slow staggered text reveal with atmospheric dark background.
class SelfReflectionScreen extends StatelessWidget {
  final VoidCallback onChat;
  final VoidCallback onRecheck;
  final VoidCallback onExit;
  final VoidCallback? onBack;

  const SelfReflectionScreen({
    super.key,
    required this.onChat,
    required this.onRecheck,
    required this.onExit,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF020203),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Atmospheric gradients
          const _AtmosphericBackground(),

          // Scrollable content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 20, 32, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  if (onBack != null)
                    CupertinoButton(
                      padding: const EdgeInsets.only(bottom: 16),
                      onPressed: onBack,
                      child: const Icon(
                        CupertinoIcons.chevron_left,
                        size: 24,
                        color: Color(0x4DFFFFFF),
                      ),
                    ),

                  // Header
                  _StaggeredBlock(
                    delay: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '你现在的位置',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            color: Color(0xCCFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 64),

                  // Block 1: status feedback
                  _StaggeredBlock(
                    delay: 1200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '你已经检查了可能留下痕迹的大部分环节。',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0x99FFFFFF),
                            fontWeight: FontWeight.w300,
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '如果这些内容都已处理，短期风险通常较低。',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0x99FFFFFF),
                            fontWeight: FontWeight.w300,
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.only(left: 16),
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Color(0x1AFFFFFF),
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            '但真正的压力，往往来自内心，而不是记录。',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xCCFFFFFF),
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.italic,
                              height: 1.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 64),

                  // Block 2: psychological support
                  _StaggeredBlock(
                    delay: 2400,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '有些关系，并不是计划发生的。',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0x80FFFFFF),
                            fontWeight: FontWeight.w300,
                            height: 1.8,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '有些决定，是在情绪、孤独、或者一瞬间的失控里发生的。',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0x80FFFFFF),
                            fontWeight: FontWeight.w300,
                            height: 1.8,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '你不是第一个经历这种混乱的人。',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0x80FFFFFF),
                            fontWeight: FontWeight.w300,
                            height: 1.8,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '重要的不是已经发生了什么，而是你接下来想要什么。',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0x99A5B4FC),
                            fontWeight: FontWeight.w500,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 64),

                  // Block 3: stress analysis card
                  _StaggeredBlock(
                    delay: 3600,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0x05FFFFFF),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: const Color(0x0DFFFFFF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '长期压力来源分析',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0x33FFFFFF),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...['隐瞒带来的心理负担', '被发现的担忧', '关系本身的变化']
                              .map((text) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: const BoxDecoration(
                                            color: Color(0x1AFFFFFF),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          text,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0x66FFFFFF),
                                            height: 1.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                          const SizedBox(height: 8),
                          const Text(
                            '如果你感到焦虑，这是正常反应。',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0x4DFFFFFF),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 64),

                  // Block 4: action buttons
                  _StaggeredBlock(
                    delay: 4800,
                    child: Column(
                      children: [
                        // AI chat button
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: onChat,
                          child: Container(
                            height: 64,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: const Color(0x0DFFFFFF),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0x1AFFFFFF)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '我想整理一下自己的想法',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xCCFFFFFF),
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  CupertinoIcons.chat_bubble,
                                  size: 20,
                                  color: Color(0x33FFFFFF),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Recheck + Exit row
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: onRecheck,
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0x05FFFFFF),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: const Color(0x0DFFFFFF)),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.arrow_2_circlepath,
                                        size: 12,
                                        color: Color(0x4DFFFFFF),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '再检查一次',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0x4DFFFFFF),
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: onExit,
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0x05FFFFFF),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: const Color(0x0DFFFFFF)),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.xmark_square,
                                        size: 12,
                                        color: Color(0x4DFFFFFF),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '退出',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0x4DFFFFFF),
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Footer decoration
                  _StaggeredBlock(
                    delay: 4800,
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.star,
                            size: 16,
                            color: Color(0x1AFFFFFF),
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            height: 48,
                            width: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x1AFFFFFF),
                                    Color(0x00FFFFFF),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Atmospheric breathing gradients ───────────────────────────

class _AtmosphericBackground extends StatelessWidget {
  const _AtmosphericBackground();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        // Indigo breathing orb (top-center)
        Positioned(
          top: size.height * 0.25,
          left: 0,
          right: 0,
          child: Container(
            height: size.width * 1.5,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0x334E5CA0), Color(0x00000000)],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 8000.ms,
              )
              .custom(
                duration: 8000.ms,
                builder: (_, val, child) =>
                    Opacity(opacity: 0.1 + val * 0.05, child: child),
              ),
        ),
        // Purple orb (bottom-right)
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: size.width,
            height: size.width,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                colors: [Color(0x1A6B21A8), Color(0x00000000)],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .custom(
                duration: 10000.ms,
                builder: (_, val, child) =>
                    Opacity(opacity: 0.05 + val * 0.05, child: child),
              ),
        ),
      ],
    );
  }
}

// ── Staggered reveal block ─────────────────────────────────────
// Matches React's staggerChildren animation — each block fades in
// and slides up from blur after its delay.

class _StaggeredBlock extends StatelessWidget {
  final int delay; // milliseconds
  final Widget child;

  const _StaggeredBlock({required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 2000.ms)
        .slideY(
          begin: 0.15,
          end: 0,
          delay: Duration(milliseconds: delay),
          duration: 2000.ms,
          curve: Curves.easeOut,
        )
        .blur(
          begin: const Offset(0, 10),
          end: Offset.zero,
          delay: Duration(milliseconds: delay),
          duration: 2000.ms,
        );
  }
}
