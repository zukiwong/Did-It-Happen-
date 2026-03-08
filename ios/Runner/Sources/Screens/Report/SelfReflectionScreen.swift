import SwiftUI

struct SelfReflectionScreen: View {
    let onBack : () -> Void
    let onChat : () -> Void
    let onExit : () -> Void

    @Environment(InvestigationStore.self) private var store

    private var flaggedCount: Int { store.record?.results.values.filter { $0 == "flagged" }.count ?? 0 }
    private var totalCount  : Int { kSelfQuestions.count }
    private var riskLevel   : String {
        let pct = Double(flaggedCount) / Double(totalCount)
        if pct < 0.25 { return "低风险" }
        if pct < 0.55 { return "中等风险" }
        return "高风险"
    }
    private var riskColor: Color {
        let pct = Double(flaggedCount) / Double(totalCount)
        if pct < 0.25 { return Color.emerald }
        if pct < 0.55 { return Color(hex: 0xFBBF24) }
        return Color.anomalyRed
    }

    var body: some View {
        NavigationStack {
          ZStack {
            Color(hex: 0x050505).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 8)

                    // Risk gauge
                    VStack(spacing: 16) {
                        Text("自我审视结果")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.30))
                            .kerning(4)

                        Text(riskLevel)
                            .font(.system(size: 44, weight: .ultraLight))
                            .foregroundStyle(riskColor)

                        HStack(spacing: 4) {
                            ForEach(0..<totalCount, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(i < flaggedCount ? riskColor : Color.white.opacity(0.10))
                                    .frame(maxWidth: .infinity).frame(height: 6)
                            }
                        }
                        .padding(.horizontal, 8)

                        Text("\(flaggedCount) / \(totalCount) 项符合")
                            .font(.mono(13))
                            .foregroundStyle(Color.white.opacity(0.40))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(28)
                    .background(Color.white.opacity(0.03))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.08)))
                    .padding(.bottom, 32)

                    // Reflection text
                    Text("诚实面对自己是需要勇气的。\n无论结果如何，你都值得一个真实的答案。")
                        .font(.system(size: 17, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.50))
                        .lineSpacing(6)
                        .padding(.bottom, 40)

                    // Chat button
                    Button(action: onChat) {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 17))
                                .foregroundStyle(Color.black)
                            Text("和 AI 倾诉与梳理")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(Color.black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                    .padding(.bottom, 12)

                    // Exit button
                    Button(action: onExit) {
                        Text("返回首页")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.40))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, 28)
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
          }
          .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
