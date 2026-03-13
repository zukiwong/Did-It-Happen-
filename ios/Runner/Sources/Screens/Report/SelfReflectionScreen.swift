import SwiftUI

struct SelfReflectionScreen: View {
    let onBack : () -> Void
    let onChat : () -> Void
    let onExit : () -> Void

    @Environment(InvestigationStore.self) private var store

    private var flaggedCount: Int { store.record?.results.values.filter { $0 == "flagged" }.count ?? 0 }
    private var totalCount  : Int { store.record?.results.count ?? kSelfQuestions.count }
    private var riskScore   : Int {
        guard totalCount > 0 else { return 0 }
        return Int(Double(flaggedCount) / Double(totalCount) * 100)
    }
    private var riskLabel: String {
        switch riskScore {
        case 0..<25:  return "暂无明显倾向"
        case 25..<55: return "存在情感风险"
        default:      return "高度需要正视"
        }
    }
    private let accent = Color(hex: 0xE8A830)

    var body: some View {
        NavigationStack {
          ZStack {
            Color(hex: 0x050505).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    heroCard
                        .padding(.top, 16)
                        .padding(.bottom, 28)

                    Text("诚实面对自己是需要勇气的。\n无论结果如何，你都值得一个真实的答案。")
                        .font(.system(size: 17, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.50))
                        .lineSpacing(8)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 40)

                    Button(action: onChat) {
                        HStack(spacing: 10) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 16))
                            Text("我想聊聊")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                    .padding(.bottom, 12)

                    Button(action: onExit) {
                        Text("返回首页")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.30))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, 20)
            }
          }
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
              ToolbarItem(placement: .navigationBarLeading) {
                  Button(action: onBack) {
                      Image(systemName: "chevron.left")
                          .font(.system(size: 17, weight: .medium))
                          .foregroundStyle(Color.white.opacity(0.60))
                  }
              }
              ToolbarItem(placement: .principal) {
                  Text("自我审视")
                      .font(.system(size: 15, weight: .semibold))
                      .foregroundStyle(Color.white.opacity(0.60))
              }
          }
          .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Hero card

    private var heroCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24).fill(Color(hex: 0x1A1008))

            GeometryReader { geo in
                RadialGradient(
                    colors: [Color(hex: 0xC05010).opacity(0.75), Color(hex: 0x8B3010).opacity(0.45), .clear],
                    center: UnitPoint(x: 0.5, y: 0),
                    startRadius: 0,
                    endRadius: geo.size.width * 0.80
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }

            VStack(spacing: 0) {
                // Small label
                Text(riskLabel)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.70))
                    .padding(.top, 28)
                    .padding(.bottom, 12)

                // Big number
                HStack(alignment: .top, spacing: 0) {
                    Text("\(flaggedCount)")
                        .font(.system(size: 88, weight: .semibold, design: .rounded))
                        .foregroundStyle(accent)
                        .lineLimit(1)
                    Text(" / \(totalCount)")
                        .font(.system(size: 32, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.70))
                        .padding(.top, 18)
                        .padding(.leading, 4)
                }
                .padding(.bottom, 20)

                // Progress bar with dot indicator
                GeometryReader { geo in
                    let progress = CGFloat(riskScore) / 100.0
                    let dotX = min(geo.size.width * progress, geo.size.width - 7)

                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 3)
                        Capsule()
                            .fill(LinearGradient(
                                colors: [Color.white.opacity(0.40), accent],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .frame(width: max(0, dotX), height: 3)
                        Circle()
                            .fill(accent)
                            .frame(width: 14, height: 14)
                            .shadow(color: accent.opacity(0.60), radius: 6)
                            .offset(x: max(0, dotX - 7))
                    }
                }
                .frame(height: 14)
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 260)
    }
}
