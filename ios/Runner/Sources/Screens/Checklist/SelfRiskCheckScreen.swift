import SwiftUI

struct SelfRiskCheckScreen: View {
    let onBack    : () -> Void
    let onComplete: () -> Void

    @Environment(InvestigationStore.self) private var store
    @State private var currentIndex = 0
    @State private var direction    = 0

    private var questions: [QuestionItem] { kSelfQuestions }
    private var current  : QuestionItem   { questions[currentIndex] }
    private var isLast   : Bool           { currentIndex == questions.count - 1 }
    private var itemId   : String         { "\(current.id)" }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: 0x0A0A0A).ignoresSafeArea()
            ambientBg

            VStack(spacing: 0) {
                topBar.padding(.top, safeAreaTop)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 8) {
                            Text("#\(String(format: "%02d", current.id))")
                                .font(.mono(9)).foregroundStyle(Color.white.opacity(0.20)).kerning(4)
                            Text(current.category)
                                .font(.system(size: 9, weight: .bold)).foregroundStyle(Color.white.opacity(0.30)).kerning(4)
                        }
                        .padding(.bottom, 16)

                        Text(current.title)
                            .font(.system(size: 22, weight: .light))
                            .foregroundStyle(Color.white.opacity(0.90))
                            .lineSpacing(6)
                            .padding(.bottom, 32)

                        ForEach(current.points, id: \.self) { point in
                            HStack(alignment: .top, spacing: 12) {
                                Circle().fill(Color.white.opacity(0.10)).frame(width: 4, height: 4).padding(.top, 6)
                                Text(point).font(.system(size: 13, weight: .light)).foregroundStyle(Color.white.opacity(0.50)).lineSpacing(4)
                            }
                            .padding(.vertical, 8).padding(.horizontal, 12)
                            .background(Color.white.opacity(0.03))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08)))
                            .padding(.bottom, 8)
                        }
                    }
                    .padding(28)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .id(currentIndex)
                .transition(.asymmetric(
                    insertion:  .move(edge: direction >= 0 ? .trailing : .leading).combined(with: .opacity),
                    removal:    .move(edge: direction >= 0 ? .leading  : .trailing).combined(with: .opacity)
                ))
                .animation(.spring(duration: 0.35), value: currentIndex)

                Spacer()
            }

            // Answer buttons
            HStack(spacing: 12) {
                answerButton(label: "没有", isPrimary: false) {
                    store.markResult(itemId: itemId, status: "normal")
                    advance()
                }
                answerButton(label: "有过", isPrimary: true) {
                    store.markResult(itemId: itemId, status: "flagged")
                    advance()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, safeAreaBottom + 16)
            .padding(.top, 48)
            .background(LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top))
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func answerButton(label: String, isPrimary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isPrimary ? Color.black : Color.white.opacity(0.80))
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(isPrimary ? Color.white : Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(isPrimary ? Color.clear : Color.white.opacity(0.15)))
        }
    }

    private var topBar: some View {
        HStack(spacing: 16) {
            Button(action: handlePrev) {
                Image(systemName: "chevron.left").font(.system(size: 18)).foregroundStyle(Color.white.opacity(0.60)).frame(width: 44, height: 44)
            }
            WaveformProgressView(current: currentIndex + 1, total: questions.count, accentColor: Color.white.opacity(0.60))
            Text("\(currentIndex + 1)/\(questions.count)").font(.mono(10)).foregroundStyle(Color.white.opacity(0.30))
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    private var ambientBg: some View {
        GeometryReader { geo in
            RadialGradient(colors: [Color(hex: 0x1D3557).opacity(0.12), .clear],
                           center: UnitPoint(x: 0.8, y: 0.1), startRadius: 0, endRadius: geo.size.width * 0.8)
                .ignoresSafeArea()
        }
    }

    private func advance() {
        if isLast { onComplete() } else {
            withAnimation { direction = 1; currentIndex += 1 }
        }
    }

    private func handlePrev() {
        if currentIndex > 0 { withAnimation { direction = -1; currentIndex -= 1 } }
        else { onBack() }
    }

    private var safeAreaTop   : CGFloat { (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top    ?? 44 }
    private var safeAreaBottom: CGFloat { (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom ?? 34 }
}
