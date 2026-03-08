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
        NavigationStack {
          ZStack(alignment: .bottom) {
            Color(hex: 0x0A0A0A).ignoresSafeArea()
            ambientBg

            questionCard
                .id(currentIndex)
                .transition(.asymmetric(
                    insertion:  .move(edge: direction >= 0 ? .trailing : .leading).combined(with: .opacity),
                    removal:    .move(edge: direction >= 0 ? .leading  : .trailing).combined(with: .opacity)
                ))
                .animation(.spring(duration: 0.35), value: currentIndex)
                .frame(maxHeight: .infinity)

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
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
              ToolbarItem(placement: .navigationBarLeading) {
                  Button(action: onBack) {
                      Image(systemName: "xmark")
                          .font(.system(size: 15, weight: .medium))
                          .foregroundStyle(Color.white.opacity(0.60))
                          .padding(8)
                          .contentShape(Circle())
                  }
                  .buttonStyle(.plain)
              }
              ToolbarItem(placement: .principal) {
                  ScrubbableProgressView(
                      current: $currentIndex,
                      total:   questions.count,
                      accentColor: Color.white.opacity(0.60)
                  )
                  .frame(width: 220)
              }
          }
          .toolbarColorScheme(.dark, for: .navigationBar)
        }
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

    private var questionCard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Text("#\(String(format: "%02d", current.id))")
                        .font(.mono(12)).foregroundStyle(Color.white.opacity(0.35)).kerning(3)
                    Text(current.category)
                        .font(.system(size: 12, weight: .bold)).foregroundStyle(Color.white.opacity(0.50)).kerning(3)
                }
                .padding(.bottom, 16)

                Text(current.title)
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(Color.white)
                    .lineSpacing(6)
                    .padding(.bottom, 32)

                ForEach(current.points, id: \.self) { point in
                    HStack(alignment: .top, spacing: 12) {
                        Circle().fill(Color.white.opacity(0.40)).frame(width: 5, height: 5).padding(.top, 7)
                        Text(point).font(.system(size: 15, weight: .light)).foregroundStyle(Color.white.opacity(0.80)).lineSpacing(4)
                    }
                    .padding(.vertical, 12).padding(.horizontal, 16)
                    .background(Color(hex: 0x1C1C1E))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.10)))
                    .padding(.bottom, 8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 160)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollContentBackground(.hidden)
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

    private var safeAreaBottom: CGFloat { (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom ?? 34 }
}
