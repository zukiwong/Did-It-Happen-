import 'dart:ui' show ImageFilter, lerpDouble;
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─────────────────────────────────────────────────────────────
// UserChoice
// ─────────────────────────────────────────────────────────────
enum UserChoice { partner, self, records }

// ─────────────────────────────────────────────────────────────
// SplashScreen — intro animation + choice UI, no screen switch
//
// Two controllers:
//   _bgCtrl  — blob background, loops at 4500ms (independent)
//   _ctrl    — main sequence, 6000ms forward-only
//
// Main timeline (t = _ctrl.value, 0→1):
//   0.02–0.28  4 dots stagger fade in
//   0.15–0.38  dot color white→black (spin feel)
//   0.38–0.60  4 dots converge → 1 golden center dot
//   0.50–0.62  blobs fade out
//   0.54–0.62  dots fade out
//   0.56–0.76  golden dot stretches into vertical divider line
//   0.70–0.98  labels + bottom button slide in
// ─────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  final ValueChanged<UserChoice> onChoice;
  const SplashScreen({super.key, required this.onChoice});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // Blob background — loops forever
  late final AnimationController _bgCtrl;
  late final Animation<double> _b1, _b2, _b3;

  // Main sequence — one-shot forward
  late final AnimationController _ctrl;

  // Tap-press highlight state
  String? _pressed;

  static double _iv(double t, double begin, double end,
      {Curve curve = Curves.linear}) {
    if (end <= begin) return t >= end ? 1.0 : 0.0;
    return curve.transform(((t - begin) / (end - begin)).clamp(0.0, 1.0));
  }

  @override
  void initState() {
    super.initState();

    // Blob background — slow sinusoidal loop
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat(reverse: true);
    _b1 = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOutSine);
    _b2 = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOutCubic);
    _b3 = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOutQuad);

    // Main sequence
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    )..forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    return ColoredBox(
      color: const Color(0xFF080808),
      child: AnimatedBuilder(
        animation: Listenable.merge([_bgCtrl, _ctrl]),
        builder: (context, _) {
          final t = _ctrl.value;

          // ── Blob positions ──────────────────────────────────
          final b1cx = lerpDouble(-0.15 * w,  0.55 * w, _b1.value)!;
          final b1cy = lerpDouble( 0.95 * h,  0.35 * h, _b1.value)!;
          final b1r  = lerpDouble(240.0, 320.0, _b1.value)!;
          final b1sc = lerpDouble(0.97,  1.05,  _b1.value)!;

          final b2cx = lerpDouble(1.10 * w,  0.42 * w, _b2.value)!;
          final b2cy = lerpDouble(0.75 * h,  0.45 * h, _b2.value)!;
          final b2r  = lerpDouble(200.0, 280.0, _b2.value)!;
          final b2sc = lerpDouble(1.03,  0.96,  _b2.value)!;

          final b3cx = lerpDouble(0.22 * w,  0.75 * w, _b3.value)!;
          final b3cy = lerpDouble(-0.08 * h, 0.22 * h, _b3.value)!;
          final b3r  = lerpDouble(170.0, 230.0, _b3.value)!;
          final b3sc = lerpDouble(0.98,  1.06,  _b3.value)!;

          // Blobs fade out as dots start merging (t 0.50→0.62)
          final blobOpacity = (1.0 - _iv(t, 0.50, 0.62, curve: Curves.easeIn))
              .clamp(0.0, 1.0);

          // ── Dot fade-in (staggered) ─────────────────────────
          final dotFade = [
            _iv(t, 0.02, 0.16, curve: Curves.easeOut), // TL
            _iv(t, 0.06, 0.20, curve: Curves.easeOut), // TR
            _iv(t, 0.10, 0.24, curve: Curves.easeOut), // BL
            _iv(t, 0.14, 0.28, curve: Curves.easeOut), // BR
          ];

          // ── Convergence ─────────────────────────────────────
          final merge = _iv(t, 0.38, 0.60, curve: Curves.easeInCubic);

          final colorSpin  = _iv(t, 0.15, 0.38, curve: Curves.easeInOut);
          final colorMerge = _iv(t, 0.38, 0.60, curve: Curves.easeOut);
          final dotColor = Color.lerp(
            Color.lerp(const Color(0xFFFFFFFF), const Color(0xFF141414), colorSpin),
            const Color(0xFFFFB800),
            colorMerge,
          )!;

          // 0.54–0.62: dots fade out
          final dotOpacity =
              (1.0 - _iv(t, 0.54, 0.62, curve: Curves.easeIn)).clamp(0.0, 1.0);

          // ── Line stretch: grows from center as a clean hairline ──
          // Width is fixed at 1px — no thickness change, just height grows.
          // Color fades from golden → dim white as line extends.
          final stretch     = _iv(t, 0.58, 0.72, curve: Curves.easeOut);
          final lineH       = lerpDouble(0.0, h * 0.64, stretch)!;
          const lineW       = 1.0;
          const lineR       = 0.25;
          final lineColor   = Color.lerp(
            const Color(0xFFFFB800), const Color(0x38FFFFFF), stretch)!;
          final lineOpacity = _iv(t, 0.58, 0.65, curve: Curves.easeOut);

          // ── Content reveal ────────────────────────────────────
          // 0.70–0.98: labels + button fade in and slide
          final content      = _iv(t, 0.70, 0.98, curve: Curves.easeOut);
          final contentSlide = lerpDouble(24.0, 0.0, content)!;


          // ── Corner dot offsets ───────────────────────────────
          const dotSize = 11.0;
          const spread  = 34.0;
          const corners = [
            Offset(-spread, -spread),
            Offset( spread, -spread),
            Offset(-spread,  spread),
            Offset( spread,  spread),
          ];

          return Stack(
            fit: StackFit.expand,
            children: [

              // ── Blob background (splash phase) ───────────────
              if (blobOpacity > 0.0)
                Opacity(
                  opacity: blobOpacity,
                  child: Stack(fit: StackFit.expand, children: [
                    _Blob(cx: b1cx, cy: b1cy, radius: b1r, scale: b1sc,
                        opacity: 0.72, blurSigma: 90,
                        colors: const [Color(0xFFFF8A3D), Color(0xFFFFB199), Color(0x00FFB199)]),
                    _Blob(cx: b2cx, cy: b2cy, radius: b2r, scale: b2sc,
                        opacity: 0.58, blurSigma: 85,
                        colors: const [Color(0xFFFF6FAF), Color(0xFFFFC3E0), Color(0x00FFC3E0)]),
                    _Blob(cx: b3cx, cy: b3cy, radius: b3r, scale: b3sc,
                        opacity: 0.35, blurSigma: 80,
                        colors: const [Color(0xFFFFD36B), Color(0xFFFFE7A6), Color(0x00FFE7A6)]),
                  ]),
                ),

              // ── Choice ambient background (fades in with content) ──
              // Left side: cold blue-teal, right side: deep rose
              // Very subtle — just enough to break the full black
              if (content > 0.0)
                IgnorePointer(
                  child: Opacity(
                    opacity: content * 0.9,
                    child: Stack(fit: StackFit.expand, children: [
                      // Left ambient — cold teal, bottom-left corner
                      Positioned(
                        left: -w * 0.25, bottom: -h * 0.05,
                        child: _StaticBlob(
                          size: w * 1.1,
                          color: const Color(0xFF0D3D50),
                          opacity: 0.55,
                          blur: 110,
                        ),
                      ),
                      // Right ambient — deep rose, top-right corner
                      Positioned(
                        right: -w * 0.25, top: -h * 0.05,
                        child: _StaticBlob(
                          size: w * 1.0,
                          color: const Color(0xFF3D0A18),
                          opacity: 0.55,
                          blur: 110,
                        ),
                      ),
                    ]),
                  ),
                ),

              // ── Vignette ────────────────────────────────────
              if (blobOpacity > 0.0)
                IgnorePointer(
                  child: Opacity(
                    opacity: blobOpacity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.2,
                          colors: [
                            const Color(0x00000000),
                            const Color(0xFF000000).withValues(alpha: 0.32),
                          ],
                          stops: const [0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

              // ── 4 corner dots ────────────────────────────────
              if (t < 0.62)
                Center(
                  child: SizedBox(
                    width:  (spread + dotSize) * 2,
                    height: (spread + dotSize) * 2,
                    child: Stack(
                      alignment: Alignment.center,
                      children: List.generate(4, (i) {
                        final dx = lerpDouble(corners[i].dx, 0.0, merge)!;
                        final dy = lerpDouble(corners[i].dy, 0.0, merge)!;
                        final sc = lerpDouble(1.0, 0.55, merge)!;
                        return Opacity(
                          opacity: dotFade[i] * dotOpacity,
                          child: Transform.translate(
                            offset: Offset(dx, dy),
                            child: Transform.scale(
                              scale: sc,
                              child: Container(
                                width: dotSize, height: dotSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: dotColor,
                                  boxShadow: colorMerge > 0.1 ? [
                                    BoxShadow(
                                      color: const Color(0xFFFFB800)
                                          .withValues(alpha: colorMerge * 0.6),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ] : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

              // ── Divider line — golden dot stretches into hairline ──
              if (t >= 0.56)
                Center(
                  child: Opacity(
                    opacity: lineOpacity,
                    child: Container(
                      width: lineW,
                      height: lineH,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(lineR),
                        color: lineColor,
                      ),
                    ),
                  ),
                ),

              // ── Left tap zone + label ─────────────────────────
              if (t >= 0.68)
                Positioned(
                  left: 0, right: w / 2 + 1, top: 0, bottom: 0,
                  child: GestureDetector(
                    onTapDown:  (_) => setState(() => _pressed = 'left'),
                    onTapUp:    (_) { setState(() => _pressed = null); widget.onChoice(UserChoice.partner); },
                    onTapCancel: () => setState(() => _pressed = null),
                    child: Stack(children: [
                      AnimatedOpacity(
                        opacity: _pressed == 'left' ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 150),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(-0.3, 0), radius: 1.1,
                              colors: [
                                const Color(0xFF1A4A5E).withValues(alpha: 0.35),
                                const Color(0x00000000),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Opacity(
                          opacity: content,
                          child: Transform.translate(
                            offset: Offset(-contentSlide, 0),
                            child: _Label(line1: 'TA', line2: '出轨了',
                                bright: _pressed == 'left'),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),

              // ── Right tap zone + label ────────────────────────
              if (t >= 0.68)
                Positioned(
                  right: 0, left: w / 2 + 1, top: 0, bottom: 0,
                  child: GestureDetector(
                    onTapDown:  (_) => setState(() => _pressed = 'right'),
                    onTapUp:    (_) { setState(() => _pressed = null); widget.onChoice(UserChoice.self); },
                    onTapCancel: () => setState(() => _pressed = null),
                    child: Stack(children: [
                      AnimatedOpacity(
                        opacity: _pressed == 'right' ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 150),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(0.3, 0), radius: 1.1,
                              colors: [
                                const Color(0xFF4A1A24).withValues(alpha: 0.35),
                                const Color(0x00000000),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Opacity(
                          opacity: content,
                          child: Transform.translate(
                            offset: Offset(contentSlide, 0),
                            child: _Label(line1: '我', line2: '出轨了',
                                bright: _pressed == 'right'),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),

              // ── Bottom records link ───────────────────────────
              if (t >= 0.68)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: GestureDetector(
                    onTap: () => widget.onChoice(UserChoice.records),
                    child: Opacity(
                      opacity: content,
                      child: Transform.translate(
                        offset: Offset(0, lerpDouble(16.0, 0.0, content)!),
                        child: const _RecordsLink(),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// StaticBlob — fixed-position ambient blob (choice background)
// ─────────────────────────────────────────────────────────────
class _StaticBlob extends StatelessWidget {
  final double size, opacity, blur;
  final Color color;
  const _StaticBlob({
    required this.size,
    required this.color,
    required this.opacity,
    required this.blur,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Blob — splash background cloud
// ─────────────────────────────────────────────────────────────
class _Blob extends StatelessWidget {
  final double cx, cy, radius, scale, opacity, blurSigma;
  final List<Color> colors;
  const _Blob({
    required this.cx, required this.cy,
    required this.radius, required this.scale,
    required this.opacity, required this.blurSigma,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return Positioned(
      left: cx - radius, top: cy - radius,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              width: size, height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.2, -0.15),
                  radius: 0.95,
                  colors: colors,
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Label
// ─────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String line1, line2;
  final bool bright;
  const _Label({required this.line1, required this.line2, required this.bright});

  @override
  Widget build(BuildContext context) {
    final op = bright ? 1.0 : 0.78;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(line1,
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400,
              letterSpacing: 8, height: 1.1,
              color: Color.fromRGBO(255, 255, 255, op))),
        const SizedBox(height: 6),
        Text(line2,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400,
              letterSpacing: 10,
              color: Color.fromRGBO(255, 255, 255, op * 0.55))),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Records link — bottom waveform + text
// ─────────────────────────────────────────────────────────────
class _RecordsLink extends StatelessWidget {
  const _RecordsLink();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xBB000000), Color(0x00000000)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(18, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: const SizedBox(width: 2, height: 8)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .custom(
                      duration: Duration(milliseconds: 1400 + i * 100),
                      delay: Duration(milliseconds: i * 70),
                      builder: (_, val, _) => SizedBox(
                        width: 2,
                        height: 4 + val * 14,
                        child: ColoredBox(
                          color: Color.fromRGBO(255, 255, 255, 0.22 + val * 0.55),
                        ),
                      ),
                    ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('查看记录',
                style: TextStyle(color: Color(0x99FFFFFF), fontSize: 15,
                    letterSpacing: 5, fontWeight: FontWeight.w400)),
              const SizedBox(width: 8),
              const Text('→', style: TextStyle(color: Color(0x99FFFFFF), fontSize: 15))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveX(begin: 0, end: 5, duration: 1500.ms, curve: Curves.easeInOut),
            ],
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
