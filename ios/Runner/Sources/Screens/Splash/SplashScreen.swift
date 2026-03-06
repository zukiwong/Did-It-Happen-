import SwiftUI

// MARK: - SplashScreen
// Replicates the Flutter animation timeline:
//   0.0–0.28  4 dots stagger in
//   0.15–0.38 dots turn white → black
//   0.38–0.60 dots converge to 1 golden center dot
//   0.50–0.62 blobs + dots fade out
//   0.56–0.76 golden dot stretches into vertical divider line
//   0.70–0.98 labels + bottom buttons slide in

struct SplashScreen: View {
    let onChoice: (UserChoice) -> Void

    // Animation progress 0→1 over 6 seconds
    @State private var t        : CGFloat = 0
    @State private var bgPhase  : CGFloat = 0  // blob loop (4.5s)
    @State private var pressed  : UserChoice? = nil

    private let totalDuration   : Double = 6.0
    private let blobDuration    : Double = 4.5

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ── Blob background ──────────────────────────────
                blobBackground(geo: geo)

                // ── Center animation ─────────────────────────────
                centerAnimation(geo: geo)

                // ── Bottom choice buttons ─────────────────────────
                VStack {
                    Spacer()
                    bottomButtons(geo: geo)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
        }
        .onAppear { startAnimations() }
    }

    // MARK: - Blob background

    @ViewBuilder
    private func blobBackground(geo: GeometryProxy) -> some View {
        let w = geo.size.width
        let h = geo.size.height
        let b1 = 0.5 + 0.5 * sin(bgPhase * 2 * .pi)
        let b2 = 0.5 + 0.5 * sin(bgPhase * 2 * .pi + 2.1)
        let b3 = 0.5 + 0.5 * sin(bgPhase * 2 * .pi + 4.2)

        let blobsAlpha = 1 - iv(t, 0.50, 0.62)

        ZStack {
            // Blob 1 — top left, blue-purple
            Ellipse()
                .fill(
                    RadialGradient(colors: [Color(hex: 0x1a1060).opacity(0.7), .clear],
                                   center: .center, startRadius: 0, endRadius: w * 0.5)
                )
                .frame(width: w * 1.2, height: w * 1.2)
                .offset(x: -w * 0.3 + w * 0.1 * CGFloat(b1),
                        y: -h * 0.2 + h * 0.05 * CGFloat(b1))
                .scaleEffect(0.8 + 0.2 * b1)

            // Blob 2 — right
            Ellipse()
                .fill(
                    RadialGradient(colors: [Color(hex: 0x0d2040).opacity(0.5), .clear],
                                   center: .center, startRadius: 0, endRadius: w * 0.4)
                )
                .frame(width: w * 0.9, height: w * 0.9)
                .offset(x: w * 0.35 + w * 0.08 * CGFloat(b2),
                        y: h * 0.1 + h * 0.05 * CGFloat(b2))
                .scaleEffect(0.9 + 0.15 * b2)

            // Blob 3 — bottom center
            Ellipse()
                .fill(
                    RadialGradient(colors: [Color(hex: 0x160830).opacity(0.4), .clear],
                                   center: .center, startRadius: 0, endRadius: w * 0.35)
                )
                .frame(width: w * 0.8, height: w * 0.8)
                .offset(x: w * 0.05 + w * 0.06 * CGFloat(b3),
                        y: h * 0.3 + h * 0.04 * CGFloat(b3))
        }
        .opacity(blobsAlpha)
    }

    // MARK: - Center animation

    @ViewBuilder
    private func centerAnimation(geo: GeometryProxy) -> some View {
        let w = geo.size.width

        // 4 dots positions (relative to center)
        let radius: CGFloat = 24
        let dotPositions: [CGPoint] = [
            CGPoint(x: -radius, y: -radius),
            CGPoint(x:  radius, y: -radius),
            CGPoint(x: -radius, y:  radius),
            CGPoint(x:  radius, y:  radius),
        ]

        ZStack {
            // ── 4 dots ───────────────────────────────────────────
            ForEach(0..<4, id: \.self) { i in
                let delay    = Double(i) * 0.06  // stagger within [0.02,0.28]
                let fadeIn   = iv(t, 0.02 + delay, 0.28 + delay)
                let whitePct = iv(t, 0.15, 0.38, curve: .easeInOut)
                let dotColor = Color.white.opacity(0.3 + 0.7 * whitePct)

                // Converge to center
                let convergePct = iv(t, 0.38, 0.60, curve: .easeInOut)
                let pos = dotPositions[i]
                let x   = pos.x * (1 - convergePct)
                let y   = pos.y * (1 - convergePct)

                let dotsAlpha = 1 - iv(t, 0.54, 0.62)

                Circle()
                    .fill(dotColor)
                    .frame(width: 8, height: 8)
                    .offset(x: x, y: y)
                    .opacity(fadeIn * dotsAlpha)
            }

            // ── Golden center dot ────────────────────────────────
            let goldenIn    = iv(t, 0.38, 0.50, curve: .easeOut)
            let goldenAlpha = goldenIn * (1 - iv(t, 0.54, 0.62))

            // Stretch into vertical line
            let stretchPct  = iv(t, 0.56, 0.76, curve: .easeInOut)
            let lineHeight  = 8 + (geo.size.height * 0.35 - 8) * stretchPct
            let lineWidth   = 8 * (1 - stretchPct) + 1 * stretchPct

            RoundedRectangle(cornerRadius: max(0.5, 4 * (1 - stretchPct)))
                .fill(Color.gold)
                .frame(width: lineWidth, height: lineHeight)
                .opacity(goldenAlpha + iv(t, 0.54, 0.62) * iv(t, 0.56, 0.76))

            // ── Labels ───────────────────────────────────────────
            let labelsPct = iv(t, 0.70, 0.90, curve: .easeOut)
            labelsView(geo: geo, progress: labelsPct)
        }
    }

    @ViewBuilder
    private func labelsView(geo: GeometryProxy, progress: CGFloat) -> some View {
        HStack(spacing: 0) {
            // Left label — "他出了吗"
            VStack(spacing: 8) {
                Text("他出了吗")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.90))
                Text("TRACE THE TRUTH")
                    .font(.mono(8, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.30))
                    .kerning(3)
            }
            .frame(maxWidth: .infinity)
            .offset(x: -20 * (1 - progress))

            // Right label — "我出了吗"
            VStack(spacing: 8) {
                Text("我出了吗")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.90))
                Text("FACE YOURSELF")
                    .font(.mono(8, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.30))
                    .kerning(3)
            }
            .frame(maxWidth: .infinity)
            .offset(x: 20 * (1 - progress))
        }
        .opacity(progress)
        .padding(.horizontal, 28)
    }

    // MARK: - Bottom buttons

    @ViewBuilder
    private func bottomButtons(geo: GeometryProxy) -> some View {
        let progress = iv(t, 0.78, 0.98, curve: .easeOut)

        VStack(spacing: 12) {
            // Partner button
            choiceButton(
                title: "查找出轨证据",
                subtitle: "INVESTIGATE",
                choice: .partner,
                isPrimary: true,
                progress: progress
            )

            HStack(spacing: 12) {
                // Self button
                choiceButton(
                    title: "我是否出轨了",
                    subtitle: "SELF-CHECK",
                    choice: .self,
                    isPrimary: false,
                    progress: progress
                )
                // Records button
                choiceButton(
                    title: "查看历史记录",
                    subtitle: "ARCHIVE",
                    choice: .records,
                    isPrimary: false,
                    progress: progress
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 48)
        .opacity(progress)
        .offset(y: 30 * (1 - progress))
    }

    @ViewBuilder
    private func choiceButton(
        title: String, subtitle: String,
        choice: UserChoice, isPrimary: Bool,
        progress: CGFloat
    ) -> some View {
        Button {
            onChoice(choice)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: isPrimary ? 16 : 13, weight: .medium))
                        .foregroundStyle(isPrimary ? Color.black : Color.white.opacity(0.80))
                    Text(subtitle)
                        .font(.mono(8, weight: .bold))
                        .foregroundStyle(isPrimary ? Color.black.opacity(0.40) : Color.white.opacity(0.30))
                        .kerning(3)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isPrimary ? Color.black.opacity(0.40) : Color.white.opacity(0.30))
            }
            .padding(.horizontal, 24)
            .frame(height: isPrimary ? 64 : 56)
            .background(isPrimary ? Color.white : Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: isPrimary ? 24 : 20))
            .overlay(
                RoundedRectangle(cornerRadius: isPrimary ? 24 : 20)
                    .stroke(isPrimary ? Color.clear : Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .scaleEffect(pressed == choice ? 0.97 : 1.0)
        .animation(.spring(duration: 0.15), value: pressed)
        ._onButtonGesture(pressing: { pressing in
            pressed = pressing ? choice : nil
        }, perform: {})
    }

    // MARK: - Helpers

    /// Interpolates t from [begin,end] → [0,1], clamped.
    private func iv(_ t: CGFloat, _ begin: Double, _ end: Double,
                    curve: Animation = .linear) -> CGFloat {
        guard end > begin else { return t >= end ? 1 : 0 }
        return CGFloat(((t - begin) / (end - begin)).clamped(to: 0...1))
    }

    private func startAnimations() {
        // Blob loop
        withAnimation(.linear(duration: blobDuration).repeatForever(autoreverses: false)) {
            bgPhase = 1
        }
        // Main sequence
        withAnimation(.linear(duration: totalDuration)) {
            t = 1
        }
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
