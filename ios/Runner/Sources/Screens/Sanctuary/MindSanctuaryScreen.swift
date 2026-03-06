import SwiftUI

struct MindSanctuaryScreen: View {
    let onBack: () -> Void

    @State private var messages  : [ChatMessage] = []
    @State private var inputText  = ""
    @State private var isStreaming = false
    @State private var streamingId : UUID?

    var body: some View {
        ZStack {
            Color(hex: 0x050505).ignoresSafeArea()
            sanctuaryBackground

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left").font(.system(size: 20)).foregroundStyle(Color.white.opacity(0.60))
                    }
                    Spacer()
                    Text("心理避难所").font(.system(size: 16, weight: .light)).foregroundStyle(Color.white.opacity(0.70))
                    Spacer()
                    Color.clear.frame(width: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, safeAreaTop + 12)
                .padding(.bottom, 16)

                Divider().background(Color.white.opacity(0.08))

                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if messages.isEmpty {
                                emptyState
                                    .padding(.top, 60)
                            }
                            ForEach(messages) { msg in
                                MessageBubble(message: msg)
                                    .id(msg.id)
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

                // Input bar
                inputBar
                    .padding(.bottom, safeAreaBottom)
            }
        }
        .ignoresSafeArea()
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(Color.white.opacity(0.15))
            Text("这里是你的安全空间")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(Color.white.opacity(0.50))
            Text("AI 陪伴你梳理情感，\n倾诉你的困惑与迷茫。")
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(Color.white.opacity(0.30))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity)
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("说说你的感受...", text: $inputText, axis: .vertical)
                .foregroundStyle(Color.white)
                .font(.system(size: 15))
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
                RadialGradient(
                    colors: [Color(hex: 0x0d1f3c).opacity(0.40), .clear],
                    center: UnitPoint(x: 0.3, y: 0.2),
                    startRadius: 0, endRadius: geo.size.width
                )
                RadialGradient(
                    colors: [Color(hex: 0x1a0a2e).opacity(0.30), .clear],
                    center: UnitPoint(x: 0.8, y: 0.7),
                    startRadius: 0, endRadius: geo.size.width * 0.8
                )
            }
            .ignoresSafeArea()
        }
    }

    private func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""

        let userMsg = ChatMessage(role: "user", content: text)
        messages.append(userMsg)

        // Placeholder for streaming response
        let assistantMsg = ChatMessage(role: "assistant", content: "")
        messages.append(assistantMsg)
        let msgId = assistantMsg.id
        streamingId = msgId
        isStreaming  = true

        var accumulated = ""
        do {
            try await DeepSeekService.streamChat(messages: messages.dropLast()) { delta in
                accumulated += delta
                // Update last message on main thread
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
        streamingId = nil
    }

    private var safeAreaTop   : CGFloat { (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top    ?? 44 }
    private var safeAreaBottom: CGFloat { (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom ?? 34 }
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
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(isUser ? Color.black : Color.white.opacity(0.85))
                .lineSpacing(4)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(isUser ? Color.white : Color.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isUser ? Color.clear : Color.white.opacity(0.08))
                )

            if !isUser { Spacer(minLength: 60) }
        }
    }
}
