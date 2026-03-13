import SwiftUI

struct SelfRiskCheckScreen: View {
    let onBack    : () -> Void
    let onComplete: () -> Void

    @Environment(InvestigationStore.self) private var store
    @State private var currentIndex    = 0
    @State private var direction       = 0
    @State private var questions       : [QuestionItem] = kSelfQuestions
    @State private var isLoading       = true
    @State private var selectedPoints  : Set<String> = []

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

            // Answer button
            answerButton(label: "没有") {
                store.markResult(itemId: itemId, status: "normal")
                advanceClearing()
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
                      accentColor: Color(hex: 0xF5C518)
                  )
                  .frame(width: 280)
                  .padding(.leading, 24)
              }
          }
          .toolbarColorScheme(.dark, for: .navigationBar)
          .task {
              let fetched = await QuestionService.fetchSelfQuestions()
              questions  = fetched
              isLoading  = false
          }
        }
    }

    @ViewBuilder
    private func answerButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.80))
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.15)))
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
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(Color.white)
                    .lineSpacing(6)
                    .padding(.bottom, 32)

                ForEach(current.points, id: \.self) { point in
                    let isSelected = selectedPoints.contains(point)
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedPoints.insert(point)
                        }
                        store.markResult(itemId: itemId, status: "flagged")
                        store.recordSelectedOption(itemId: itemId, point: point)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            advanceClearing()
                        }
                    } label: {
                        Text(point)
                            .font(.system(size: 17, weight: .light))
                            .foregroundStyle(isSelected ? Color.white : Color.white.opacity(0.80))
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 18).padding(.horizontal, 16)
                            .background(isSelected ? Color(hex: 0xF5C518).opacity(0.12) : Color(hex: 0x1C1C1E))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? Color(hex: 0xF5C518).opacity(0.80) : Color.white.opacity(0.10)))
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 12)
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

    private func advanceClearing() {
        selectedPoints = []
        advance()
    }

    private var safeAreaBottom: CGFloat { (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom ?? 34 }
}
