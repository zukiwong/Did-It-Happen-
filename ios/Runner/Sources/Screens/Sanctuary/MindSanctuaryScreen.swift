import SwiftUI

// MARK: - Category model

private struct SanctuaryCategory: Identifiable {
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

private let sanctuaryCategories: [SanctuaryCategory] = [
    SanctuaryCategory(id: "guilt",    title: "我很愧疚",         sub: "我不知道该怎么面对这件事",
                      aiOpener: "你现在的状态，可能有点复杂。如果你愿意，可以告诉我最近发生了什么。",
                      bgColor: Color(hex: 0xD1D5DB), textColor: .black, subColor: .black.opacity(0.50),
                      tiltDeg: -1.2, offsetY: 0),
    SanctuaryCategory(id: "complex",  title: "事情变得复杂了",   sub: "我不知道该怎么处理现在的关系",
                      aiOpener: "关系中的复杂往往源于未被察觉的信号。我们可以从理性的角度分析现状。",
                      bgColor: Color(hex: 0x262626), textColor: Color.white.opacity(0.90), subColor: Color.white.opacity(0.30),
                      tiltDeg: 1.8, offsetY: -12),
    SanctuaryCategory(id: "occurred", title: "也许事情已经发生了", sub: "我想弄清楚自己真正的想法",
                      aiOpener: "既然已经发生，与其回望，不如探索你内心真正的倾向。你现在的感受是什么？",
                      bgColor: Color(hex: 0xE2FB5E), textColor: .black, subColor: .black.opacity(0.50),
                      tiltDeg: -1.0, offsetY: -24),
]

private let sanctuaryChips = ["我不知道该说什么", "我怕被发现", "我不知道怎么办"]

// MARK: - Main screen

struct MindSanctuaryScreen: View {
    let onBack: () -> Void

    @State private var showChat      = false
    @State private var messages      : [ChatMessage] = []
    @State private var inputText     = ""
    @State private var isStreaming   = false
    @State private var activeCategory: String = "general"

    var body: some View {
        if showChat {
            chatView
        } else {
            landingView
        }
    }

    // MARK: - Landing

    private var landingView: some View {
        NavigationStack {
          ZStack {
            Color(hex: 0x0E0E10).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Header
                    Group {
                        Text("整理一下你的\n").font(.system(size: 32, weight: .light)).foregroundStyle(.white)
                        + Text("想法").font(.system(size: 32, weight: .medium)).italic().foregroundStyle(.white)
                    }
                    .lineSpacing(6)

                    Text("内心对话空间")
                        .font(.system(size: 10, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.20))
                        .kerning(8)
                        .padding(.top, 12)

                    // Stacked cards
                    ZStack(alignment: .top) {
                        ForEach(Array(sanctuaryCategories.enumerated()), id: \.element.id) { idx, cat in
                            CategoryCardView(category: cat, index: idx) {
                                startChat(categoryId: cat.id, opener: cat.aiOpener)
                            }
                            .offset(y: CGFloat(idx) * 104 + cat.offsetY)
                        }
                    }
                    .frame(height: CGFloat(sanctuaryCategories.count) * 104 + 16)
                    .padding(.top, 32)

                    // Quick chips
                    Text("快速整理")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.20))
                        .kerning(8)
                        .padding(.top, 48)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(sanctuaryChips, id: \.self) { chip in
                                Button {
                                    startChat(categoryId: "general", opener: "关于「\(chip)」，你有什么想说的吗？")
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
                        .padding(.top, 16)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 60)
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

    // MARK: - Chat

    private var chatView: some View {
        NavigationStack {
          ZStack {
            Color(hex: 0x050505).ignoresSafeArea()
            sanctuaryBackground

            VStack(spacing: 0) {
                Divider().background(Color.white.opacity(0.08))

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(messages) { msg in
                                MessageBubble(message: msg).id(msg.id)
                            }
                        }
                        .padding(20)
                    }
                    .onChange(of: messages.count) {
                        if let last = messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }

                inputBar
            }
          }
          .navigationTitle("聊天室")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
              ToolbarItem(placement: .navigationBarLeading) {
                  Button { showChat = false } label: {
                      Image(systemName: "chevron.left")
                          .font(.system(size: 17, weight: .medium))
                          .foregroundStyle(Color.white.opacity(0.60))
                  }
              }
          }
          .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("轻轻诉说你的想法...", text: $inputText, axis: .vertical)
                .foregroundStyle(Color.white)
                .font(.system(size: 15, weight: .light))
                .lineLimit(1...4)
                .padding(14)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.12)))

            Button {
                Task { await sendMessage() }
            } label: {
                Image(systemName: isStreaming ? "stop.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(inputText.isEmpty && !isStreaming ? Color.white.opacity(0.20) : Color.white)
            }
            .disabled(inputText.isEmpty && !isStreaming)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: 0x0A0A0A))
    }

    private var sanctuaryBackground: some View {
        GeometryReader { geo in
            ZStack {
                RadialGradient(colors: [Color(hex: 0x0d1f3c).opacity(0.40), .clear],
                               center: UnitPoint(x: 0.3, y: 0.2), startRadius: 0, endRadius: geo.size.width)
                RadialGradient(colors: [Color(hex: 0x1a0a2e).opacity(0.30), .clear],
                               center: UnitPoint(x: 0.8, y: 0.7), startRadius: 0, endRadius: geo.size.width * 0.8)
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Actions

    private func startChat(categoryId: String, opener: String) {
        activeCategory = categoryId
        messages = []
        showChat = true
        // Delay first AI message slightly
        Task {
            try? await Task.sleep(nanoseconds: 600_000_000)
            await MainActor.run {
                messages.append(ChatMessage(role: "assistant", content: opener))
            }
        }
    }

    private var systemPrompt: String {
        switch activeCategory {
        case "guilt":    return "You are a warm, empathetic companion helping someone process feelings of guilt in a relationship. Respond with compassion, avoid judgment, speak in Chinese, keep replies concise (2-4 sentences)."
        case "complex":  return "You are a calm, analytical relationship counselor helping someone navigate a complicated relationship situation. Offer thoughtful, rational perspective, speak in Chinese, keep replies concise (2-4 sentences)."
        case "occurred": return "You are a gentle therapist helping someone understand their true feelings after something has happened in their relationship. Encourage self-reflection, speak in Chinese, keep replies concise (2-4 sentences)."
        default:         return "You are a compassionate AI companion for emotional support in relationship situations. Respond warmly and supportively in Chinese, keep replies concise (2-4 sentences)."
        }
    }

    private func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        messages.append(ChatMessage(role: "user", content: text))

        let assistantMsg = ChatMessage(role: "assistant", content: "")
        messages.append(assistantMsg)
        let msgId = assistantMsg.id
        isStreaming = true

        var accumulated = ""
        do {
            try await DeepSeekService.streamChat(messages: messages.dropLast()) { delta in
                accumulated += delta
                DispatchQueue.main.async {
                    if let idx = self.messages.firstIndex(where: { $0.id == msgId }) {
                        self.messages[idx] = ChatMessage(role: "assistant", content: accumulated)
                    }
                }
            }
        } catch {
            if let idx = messages.firstIndex(where: { $0.id == msgId }) {
                messages[idx] = ChatMessage(role: "assistant", content: "网络异常，请重试。")
            }
        }
        isStreaming = false
    }

}

// MARK: - Category card

private struct CategoryCardView: View {
    let category: SanctuaryCategory
    let index   : Int
    let onTap   : () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                Text(category.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(category.textColor)
                Text(category.sub)
                    .font(.system(size: 11, weight: .medium))
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
                Circle()
                    .fill(Color(hex: 0x172554).opacity(0.80))
                    .frame(width: 28, height: 28)
                    .overlay(Text("AI").font(.system(size: 9, weight: .bold)).foregroundStyle(Color.white.opacity(0.60)))
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
