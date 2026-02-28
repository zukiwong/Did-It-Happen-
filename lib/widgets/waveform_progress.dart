import 'dart:math';
import 'package:flutter/widgets.dart';

// Animated waveform-style progress bar used in checklist screens
class WaveformProgress extends StatelessWidget {
  final int current;
  final int total;
  // activeColor: the color of the current active bar
  final Color activeColor;
  // pastColor: color of already-passed bars
  final Color pastColor;

  const WaveformProgress({
    super.key,
    required this.current,
    required this.total,
    this.activeColor = const Color(0xB3FFFFFF),
    this.pastColor = const Color(0xFFEF4444),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(total, (i) {
          final isActive = i == current - 1;
          final isPast = i < current - 1;
          final waveHeight = 4 + (sin(i * 0.8) * 12).abs();

          final barHeight = isActive
              ? 24.0
              : isPast
                  ? 8.0
                  : waveHeight;

          final barColor = isActive
              ? activeColor
              : isPast
                  ? pastColor
                  : const Color(0x1AFFFFFF);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.5),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                height: barHeight,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                          )
                        ]
                      : null,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
