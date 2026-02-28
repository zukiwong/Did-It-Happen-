import 'package:flutter/widgets.dart';

// Reusable SVG noise texture background overlay
class NoiseBackground extends StatelessWidget {
  final double opacity;

  const NoiseBackground({super.key, this.opacity = 0.03});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: ColoredBox(
          color: const Color(0xFF888888),
          // Real noise would use a shader; this approximation keeps deps minimal
        ),
      ),
    );
  }
}
