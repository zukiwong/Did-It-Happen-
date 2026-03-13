import SwiftUI

// MARK: - Data

struct SanctuaryCategory: Identifiable {
    let id       : String
    let title    : String
    let sub      : String
    let aiOpener : String
    let bgColor  : Color
    let textColor: Color
    let subColor : Color
    let tiltDeg  : Double
    let offsetY  : CGFloat
}

let sanctuaryCategories: [SanctuaryCategory] = [
    SanctuaryCategory(id: "guilt",    title: "我很愧疚",          sub: "我不知道该怎么面对这件事",
                      aiOpener: "你现在的状态，可能有点复杂。如果你愿意，可以告诉我最近发生了什么。",
                      bgColor: Color(hex: 0xD1D5DB), textColor: .black, subColor: .black.opacity(0.50),
                      tiltDeg: -1.2, offsetY: 0),
    SanctuaryCategory(id: "complex",  title: "事情变得复杂了",    sub: "我不知道该怎么处理现在的关系",
                      aiOpener: "关系中的复杂往往源于未被察觉的信号。我们可以从理性的角度分析现状。",
                      bgColor: Color(hex: 0x262626), textColor: Color.white.opacity(0.90), subColor: Color.white.opacity(0.30),
                      tiltDeg: 1.8, offsetY: -12),
    SanctuaryCategory(id: "occurred", title: "也许事情已经发生了", sub: "我想弄清楚自己真正的想法",
                      aiOpener: "既然已经发生，与其回望，不如探索你内心真正的倾向。你现在的感受是什么？",
                      bgColor: Color(hex: 0xE2FB5E), textColor: .black, subColor: .black.opacity(0.50),
                      tiltDeg: -1.0, offsetY: -24),
]

let sanctuaryChips = ["我不知道该说什么", "我怕被发现", "我不知道怎么办"]

// MARK: - Screen

struct MindSanctuaryScreen: View {
    let onBack  : () -> Void
    let onChat  : (String, String) -> Void   // (categoryId, opener)

    var body: some View {
        NavigationStack {
          ZStack {
            Color(hex: 0x0E0E10).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                VStack(alignment: .leading, spacing: 2) {
                    Text("整理一下你的")
                        .font(.system(size: 32, weight: .light))
                        .foregroundStyle(.white)
                    Text("想法")
                        .font(.system(size: 32, weight: .medium))
                        .italic()
                        .foregroundStyle(.white)
                }
                .padding(.top, 20)
                .padding(.horizontal, 24)

                // Stacked cards
                ZStack(alignment: .top) {
                    ForEach(Array(sanctuaryCategories.enumerated()), id: \.element.id) { idx, cat in
                        CategoryCardView(category: cat, index: idx) {
                            onChat(cat.id, cat.aiOpener)
                        }
                        .offset(y: CGFloat(idx) * 124 + cat.offsetY)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: CGFloat(sanctuaryCategories.count - 1) * 124 + 116 - 24)
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                // Quick chips
                VStack(alignment: .leading, spacing: 0) {
                    Text("快速整理")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.20))
                        .kerning(6)
                        .padding(.horizontal, 24)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(sanctuaryChips, id: \.self) { chip in
                                Button {
                                    onChat("general", "关于「\(chip)」，你有什么想说的吗？")
                                } label: {
                                    Text(chip)
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color.white.opacity(0.40))
                                        .padding(.horizontal, 20).padding(.vertical, 14)
                                        .background(Color.white.opacity(0.04))
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(Color.white.opacity(0.08)))
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                    }
                }
                .padding(.bottom, 40)
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

// MARK: - Card

struct CategoryCardView: View {
    let category: SanctuaryCategory
    let index   : Int
    let onTap   : () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                Text(category.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(category.textColor)
                Text(category.sub)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(category.subColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(28)
            .frame(height: 116)
            .background(category.bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 26))
            .shadow(color: .black.opacity(0.25), radius: 24, x: 0, y: 8)
        }
        .rotationEffect(.degrees(category.tiltDeg))
    }
}

// MARK: - Message bubble

struct MessageBubble: View {
    let message: ChatMessage

    private var isUser: Bool { message.role == "user" }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 60) }

            if !isUser {
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
            }

            Text(message.content.isEmpty ? "▌" : message.content)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(isUser ? Color.black : Color.white.opacity(0.85))
                .lineSpacing(4)
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(isUser ? Color.white : Color.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(isUser ? Color.clear : Color.white.opacity(0.08)))

            if !isUser { Spacer(minLength: 60) }
        }
    }
}
