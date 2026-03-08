import SwiftUI

// MARK: - SplashScreen
// Driven by TimelineView(.animation) for per-frame t calculation.
//
// Timeline (t = 0→1 over 5.5s):
//   0.02–0.28  4 dots stagger fade in
//   0.15–0.38  dot color white → black (colorSpin)
//   0.38–0.60  dots converge + color → gold (merge)
//   0.50–0.62  blobs fade out
//   0.54–0.62  dots fade out
//   0.58–0.72  hairline grows, gold → dim-white
//   0.70–0.98  labels + bottom link slide in

struct SplashScreen: View {
    let onChoice: (UserChoice) -> Void

    @State private var startDate: Date? = nil
    @State private var blobStart: Date? = nil
    @State private var pressedLeft  = false
    @State private var pressedRight = false

    private let mainDuration: Double  = 5.5
    private let blobDuration: Double  = 4.5

    var body: some View {
        TimelineView(.animation) { tl in
            let now = tl.date

            // t: 0→1 over mainDuration, then clamped at 1
            let t: CGFloat = {
                guard let s = startDate else { return 0 }
                return CGFloat(min(now.timeIntervalSince(s) / mainDuration, 1.0))
            }()

            // bgRaw: 0→1→0→1... bouncing with period blobDuration each way
            let bgRaw: CGFloat = {
                guard let s = blobStart else { return 0 }
                let elapsed = now.timeIntervalSince(s)
                let cycle   = elapsed / blobDuration
                let phase   = cycle.truncatingRemainder(dividingBy: 2.0)
                return phase <= 1.0 ? CGFloat(phase) : CGFloat(2.0 - phase)
            }()

            SplashCanvas(
                t: t, bgRaw: bgRaw,
                pressedLeft: pressedLeft, pressedRight: pressedRight,
                onChoice: onChoice,
                onPressLeft:  { pressedLeft  = $0 },
                onPressRight: { pressedRight = $0 }
            )
        }
        .ignoresSafeArea()
        .onAppear {
            startDate = Date()
            blobStart = Date()
        }
    }
}

// MARK: - Canvas (pure computed view, no @State)

private struct SplashCanvas: View {
    let t            : CGFloat
    let bgRaw        : CGFloat
    let pressedLeft  : Bool
    let pressedRight : Bool
    let onChoice     : (UserChoice) -> Void
    let onPressLeft  : (Bool) -> Void
    let onPressRight : (Bool) -> Void

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            // Per-blob easing
            let bv1 = easeInOutSine(bgRaw)
            let bv2 = easeInOutCubic(bgRaw)
            let bv3 = easeInOutQuad(bgRaw)

            let b1cx = lerp(-0.15 * w,  0.55 * w, bv1)
            let b1cy = lerp( 0.95 * h,  0.35 * h, bv1)
            let b1r  = lerp(240, 320, bv1)
            let b1sc = lerp(0.97, 1.05, bv1)

            let b2cx = lerp(1.10 * w,  0.42 * w, bv2)
            let b2cy = lerp(0.75 * h,  0.45 * h, bv2)
            let b2r  = lerp(200, 280, bv2)
            let b2sc = lerp(1.03, 0.96, bv2)

            let b3cx = lerp(0.22 * w,  0.75 * w, bv3)
            let b3cy = lerp(-0.08 * h, 0.22 * h, bv3)
            let b3r  = lerp(170, 230, bv3)
            let b3sc = lerp(0.98, 1.06, bv3)

            let blobOpacity = 1.0 - iv(t, 0.50, 0.62, curve: .easeIn)

            // Dots
            let dotFade: [CGFloat] = [
                iv(t, 0.02, 0.16, curve: .easeOut),
                iv(t, 0.06, 0.20, curve: .easeOut),
                iv(t, 0.10, 0.24, curve: .easeOut),
                iv(t, 0.14, 0.28, curve: .easeOut),
            ]
            let merge      = iv(t, 0.38, 0.60, curve: .easeIn)
            let colorSpin  = iv(t, 0.15, 0.38, curve: .easeInOut)
            let colorMerge = iv(t, 0.38, 0.60, curve: .easeOut)
            let spinR = lerp(1.0, 0.08, colorSpin)
            let spinG = lerp(1.0, 0.08, colorSpin)
            let spinB = lerp(1.0, 0.08, colorSpin)
            let dotR  = lerp(spinR, 1.0,   colorMerge)
            let dotG  = lerp(spinG, 0.722, colorMerge)
            let dotB  = lerp(spinB, 0.0,   colorMerge)
            let dotColor   = Color(red: dotR, green: dotG, blue: dotB)
            let goldGlow   = colorMerge > 0.1
            let dotOpacity = 1.0 - iv(t, 0.54, 0.62, curve: .easeIn)

            let spread: CGFloat = 34
            let corners: [CGSize] = [
                CGSize(width: -spread, height: -spread),
                CGSize(width:  spread, height: -spread),
                CGSize(width: -spread, height:  spread),
                CGSize(width:  spread, height:  spread),
            ]

            // Line
            let stretch     = iv(t, 0.58, 0.72, curve: .easeOut)
            let lineH       = lerp(0, h * 0.64, stretch)
            let lineOpacity = iv(t, 0.58, 0.65, curve: .easeOut)
            let lineR2 = lerp(1.0, 1.0, stretch)
            let lineG2 = lerp(0.72, 1.0, stretch)
            let lineB2 = lerp(0.0,  1.0, stretch)
            let lineA  = lerp(1.0,  0.22, stretch)
            let lineColor = Color(red: lineR2, green: lineG2, blue: lineB2).opacity(lineA)

            // Content
            let content      = iv(t, 0.70, 0.98, curve: .easeOut)
            let contentSlide = lerp(24.0, 0.0, content)

            ZStack {
                Color(hex: 0x080808).ignoresSafeArea()

                // Blobs
                if blobOpacity > 0 {
                    ZStack {
                        BlobView(cx: b1cx, cy: b1cy, radius: b1r, scale: b1sc,
                                 opacity: 0.72, blurSigma: 90,
                                 innerColor: Color(hex: 0xFF8A3D), midColor: Color(hex: 0xFFB199))
                        BlobView(cx: b2cx, cy: b2cy, radius: b2r, scale: b2sc,
                                 opacity: 0.58, blurSigma: 85,
                                 innerColor: Color(hex: 0xFF6FAF), midColor: Color(hex: 0xFFC3E0))
                        BlobView(cx: b3cx, cy: b3cy, radius: b3r, scale: b3sc,
                                 opacity: 0.35, blurSigma: 80,
                                 innerColor: Color(hex: 0xFFD36B), midColor: Color(hex: 0xFFE7A6))
                    }
                    .opacity(blobOpacity)

                    RadialGradient(
                        colors: [Color.clear, Color.black.opacity(0.32)],
                        center: .center,
                        startRadius: min(w, h) * 0.55,
                        endRadius:   max(w, h) * 0.9
                    )
                    .ignoresSafeArea()
                    .opacity(blobOpacity)
                    .allowsHitTesting(false)
                }

                // Choice ambient
                if content > 0 {
                    ZStack {
                        BlurredCircle(color: Color(hex: 0x1A7A9A), size: w * 1.3, blur: 100, opacity: 0.90)
                            .offset(x: -w * 0.25 - w * 0.55 + w/2, y: h * 0.5 - h * 0.05 - w * 0.55)
                        BlurredCircle(color: Color(hex: 0x8B1530), size: w * 1.2, blur: 100, opacity: 0.90)
                            .offset(x: w * 0.25 + w * 0.5 - w/2, y: -h * 0.05 - w * 0.5)
                    }
                    .opacity(content * 0.9)
                    .allowsHitTesting(false)
                }

                // Dots
                if t < 0.63 {
                    ZStack {
                        ForEach(0..<4, id: \.self) { i in
                            let dx = lerp(corners[i].width,  0, merge)
                            let dy = lerp(corners[i].height, 0, merge)
                            let sc = lerp(1.0, 0.55, merge)
                            Circle()
                                .fill(dotColor)
                                .frame(width: 11, height: 11)
                                .shadow(color: goldGlow ? Color(hex: 0xFFB800).opacity(colorMerge * 0.6) : .clear,
                                        radius: 12)
                                .scaleEffect(sc)
                                .offset(x: dx, y: dy)
                                .opacity(dotFade[i] * dotOpacity)
                        }
                    }
                }

                // Hairline
                if t >= 0.56 {
                    Rectangle()
                        .fill(lineColor)
                        .frame(width: 1, height: lineH)
                        .opacity(lineOpacity)
                }

                // Choice tap zones
                if t >= 0.68 {
                    HStack(spacing: 0) {
                        ZStack {
                            RadialGradient(
                                colors: [Color(hex: 0x1A6A8E).opacity(pressedLeft ? 0.55 : 0), .clear],
                                center: UnitPoint(x: 0.35, y: 0.5),
                                startRadius: 0, endRadius: w * 0.7
                            )
                            .animation(.easeOut(duration: 0.18), value: pressedLeft)
                            SplashLabel(line1: "TA", line2: "出轨了", bright: pressedLeft)
                                .offset(x: -contentSlide)
                                .opacity(content)
                                .scaleEffect(pressedLeft ? 0.93 : 1.0)
                                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: pressedLeft)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in onPressLeft(true) }
                                .onEnded   { _ in onPressLeft(false); onChoice(.partner) }
                        )

                        ZStack {
                            RadialGradient(
                                colors: [Color(hex: 0x6E1A2E).opacity(pressedRight ? 0.55 : 0), .clear],
                                center: UnitPoint(x: 0.65, y: 0.5),
                                startRadius: 0, endRadius: w * 0.7
                            )
                            .animation(.easeOut(duration: 0.18), value: pressedRight)
                            SplashLabel(line1: "我", line2: "出轨了", bright: pressedRight)
                                .offset(x: contentSlide)
                                .opacity(content)
                                .scaleEffect(pressedRight ? 0.93 : 1.0)
                                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: pressedRight)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in onPressRight(true) }
                                .onEnded   { _ in onPressRight(false); onChoice(.self) }
                        )
                    }
                    .ignoresSafeArea()
                }

                // Records link
                if t >= 0.68 {
                    VStack {
                        Spacer()
                        RecordsLink(onTap: { onChoice(.records) })
                            .offset(y: lerp(16, 0, content))
                            .opacity(content)
                    }
                }
            }
            .frame(width: w, height: h)
        }
        .ignoresSafeArea()
    }

    // MARK: - Math helpers

    private func iv(_ t: CGFloat, _ begin: Double, _ end: Double, curve: AnimCurve = .linear) -> CGFloat {
        guard end > begin else { return t >= CGFloat(end) ? 1 : 0 }
        let raw = min(1, max(0, (t - CGFloat(begin)) / CGFloat(end - begin)))
        return curve.apply(raw)
    }
    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { a + (b - a) * t }
    private func easeInOutSine(_ t: CGFloat) -> CGFloat  { -(cos(.pi * t) - 1) / 2 }
    private func easeInOutCubic(_ t: CGFloat) -> CGFloat { t < 0.5 ? 4*t*t*t : 1 - pow(-2*t+2,3)/2 }
    private func easeInOutQuad(_ t: CGFloat) -> CGFloat  { t < 0.5 ? 2*t*t   : 1 - pow(-2*t+2,2)/2 }
}

// MARK: - Curve

enum AnimCurve {
    case linear, easeIn, easeOut, easeInOut
    func apply(_ t: CGFloat) -> CGFloat {
        switch self {
        case .linear:    return t
        case .easeIn:    return t * t
        case .easeOut:   return 1 - (1 - t) * (1 - t)
        case .easeInOut: return t < 0.5 ? 2*t*t : 1 - pow(-2*t+2,2)/2
        }
    }
}

// MARK: - Blob

struct BlobView: View {
    let cx, cy, radius, scale, opacity, blurSigma: CGFloat
    let innerColor, midColor: Color

    var body: some View {
        let size = radius * 2
        Circle()
            .fill(RadialGradient(
                colors: [innerColor, midColor, midColor.opacity(0)],
                center: UnitPoint(x: 0.4, y: 0.425),
                startRadius: 0,
                endRadius: radius * 0.95
            ))
            .frame(width: size, height: size)
            .blur(radius: blurSigma)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(x: cx, y: cy)
    }
}

// MARK: - BlurredCircle

struct BlurredCircle: View {
    let color: Color
    let size, blur, opacity: CGFloat
    var body: some View {
        Circle().fill(color)
            .frame(width: size, height: size)
            .blur(radius: blur)
            .opacity(opacity)
    }
}

// MARK: - SplashLabel

struct SplashLabel: View {
    let line1, line2: String
    let bright: Bool
    var body: some View {
        let op: Double = bright ? 1.0 : 0.95
        VStack(spacing: 6) {
            Text(line1)
                .font(.system(size: 36, weight: .regular))
                .kerning(8)
                .foregroundStyle(Color.white.opacity(op))
                .padding(.leading, 8)   // compensate trailing kerning gap
            Text(line2)
                .font(.system(size: 15, weight: .regular))
                .kerning(10)
                .foregroundStyle(Color.white.opacity(op * 0.70))
                .padding(.leading, 10)  // compensate trailing kerning gap
        }
    }
}

// MARK: - RecordsLink

struct RecordsLink: View {
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [Color.black.opacity(0.73), .clear],
                    startPoint: .bottom, endPoint: .top
                )
                .frame(height: 96)
                VStack(spacing: 10) {
                    HStack(alignment: .bottom, spacing: 2) {
                        ForEach(0..<18, id: \.self) { i in
                            AnimatedBar(index: i)
                        }
                    }
                    HStack(spacing: 8) {
                        Text("查看记录")
                            .font(.system(size: 15, weight: .regular))
                            .kerning(5)
                            .foregroundStyle(Color.white.opacity(0.90))
                        Text("→")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.white.opacity(0.90))
                    }
                    Spacer().frame(height: 28)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

struct AnimatedBar: View {
    let index: Int
    @State private var height: CGFloat = 4
    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(Color.white.opacity(0.60 + Double(index % 3) * 0.18))
            .frame(width: 2, height: height)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.4 + Double(index) * 0.1)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.07)
                ) {
                    height = CGFloat.random(in: 6...18)
                }
            }
    }
}
