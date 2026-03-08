import SwiftUI
import Combine

// MARK: - Colors (match Flutter hex values)

extension Color {
    static let bg          = Color(hex: 0x050505)
    static let bgChecklist = Color(hex: 0x0A0A0A)
    static let surface     = Color.white.opacity(0.05)
    static let surfaceBold = Color.white.opacity(0.10)
    static let border      = Color.white.opacity(0.10)
    static let borderBold  = Color.white.opacity(0.20)
    static let textPrimary = Color.white.opacity(0.90)
    static let textSecond  = Color.white.opacity(0.50)
    static let textHint    = Color.white.opacity(0.20)
    static let anomalyRed  = Color(hex: 0xEF4444)
    static let anomalyRedD = Color(hex: 0xEF4444).opacity(0.10)
    static let emerald     = Color(hex: 0x34D399)
    static let gold        = Color(hex: 0xD4A853)

    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >>  8) & 0xFF) / 255,
            blue:  Double( hex        & 0xFF) / 255,
            opacity: alpha
        )
    }
}

// MARK: - Typography helpers

extension Font {
    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

// MARK: - Common view modifiers

struct CardStyle: ViewModifier {
    var expanded: Bool = false
    func body(content: Content) -> some View {
        content
            .background(expanded ? Color.white.opacity(0.10) : Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(expanded ? Color.border : Color.white.opacity(0.07), lineWidth: 1)
            )
    }
}

extension View {
    func cardStyle(expanded: Bool = false) -> some View {
        modifier(CardStyle(expanded: expanded))
    }
}

// MARK: - Recording Button
// Shows a mic icon at rest. While recording, displays 3 pulsing rings
// whose scale is driven by live audio level from EvidenceService.audioLevel().

struct RecordingButton: View {
    let isRecording: Bool
    let size       : CGFloat
    let action     : () -> Void

    @State private var level  : Float  = 0       // 0…1 from microphone
    @State private var timer  : AnyCancellable?

    // Three rings animate at different phases
    @State private var ring1 : CGFloat = 1
    @State private var ring2 : CGFloat = 1
    @State private var ring3 : CGFloat = 1

    var body: some View {
        Button(action: action) {
            ZStack {
                // Inward-shrinking rings — sit inside the button circle
                if isRecording {
                    ForEach(0..<3, id: \.self) { i in
                        let scale: CGFloat = [ring1, ring2, ring3][i]
                        let opacity = Double(0.55 - Float(i) * 0.12)
                        Circle()
                            .stroke(Color.anomalyRed.opacity(opacity), lineWidth: 1.5)
                            .frame(width: size, height: size)
                            .scaleEffect(scale)
                    }
                }

                // Icon background
                Circle()
                    .fill(isRecording ? Color.anomalyRed.opacity(0.18) : Color.white.opacity(0.10))
                    .frame(width: size, height: size)
                    .overlay(
                        // Recording: filled red dot; idle: mic icon
                        Group {
                            if isRecording {
                                Circle()
                                    .fill(Color.anomalyRed)
                                    .frame(width: size * 0.32, height: size * 0.32)
                            } else {
                                Image(systemName: "mic")
                                    .font(.system(size: size * 0.40))
                                    .foregroundStyle(Color.white.opacity(0.80))
                            }
                        }
                    )
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .onChange(of: isRecording) { _, recording in
            if recording { startMetering() } else { stopMetering() }
        }
        .onAppear {
            if isRecording { startMetering() }
        }
        .onDisappear { stopMetering() }
    }

    private func startMetering() {
        timer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                let raw = EvidenceService.audioLevel()  // 0…1
                // Smooth with simple low-pass so rings don't jitter
                level = level * 0.6 + raw * 0.4

                // Rings shrink inward with audio level: loud = more shrink
                // At silence: scale = 1.0 (full size ring); at max: scale ~= 0.30
                let boost = CGFloat(level)
                withAnimation(.easeOut(duration: 0.08)) {
                    ring1 = 1.0 - boost * 0.45
                    ring2 = 1.0 - boost * 0.62
                    ring3 = 1.0 - boost * 0.72
                }
            }
    }

    private func stopMetering() {
        timer?.cancel()
        timer = nil
        withAnimation(.easeOut(duration: 0.3)) {
            ring1 = 1; ring2 = 1; ring3 = 1
        }
        level = 0
    }
}
