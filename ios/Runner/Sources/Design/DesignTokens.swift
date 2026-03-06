import SwiftUI

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
