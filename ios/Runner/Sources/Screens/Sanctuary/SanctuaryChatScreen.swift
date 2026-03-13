import SwiftUI

struct SanctuaryChatScreen: View {
    let categoryId: String
    let opener    : String
    let onBack    : () -> Void

    @Environment(InvestigationStore.self) private var store
    @State private var messages      : [ChatMessage] = []
    @State private var inputText     = ""
    @State private var isStreaming   = false
    @StateObject private var storeService = StoreService.shared
    @State private var charsRemaining : Int = QuotaService.remaining
    @State private var showPurchaseSheet = false

    var body: some View {
        NavigationStack {
          ZStack {
            Color(hex: 0x050505).ignoresSafeArea()
            background

            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(messages) { msg in
                                MessageBubble(message: msg).id(msg.id)
                            }
                        }
                        .padding(20)
                        .padding(.top, 44)   // extend under nav bar so blur has content
                    }
                    .onChange(of: messages.count) {
                        if let last = messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                    .onChange(of: messages.last?.content) {
                        if let last = messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }

                if charsRemaining <= 750 {
                    quotaBanner
                }
                inputBar
            }
          }
          .onTapGesture { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
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
                  Text("随便聊聊")
                      .font(.system(size: 17, weight: .semibold))
                      .foregroundStyle(Color.white.opacity(0.90))
              }
          }
          .toolbarColorScheme(.dark, for: .navigationBar)
          .sheet(isPresented: $showPurchaseSheet) {
              PurchaseSheet(storeService: storeService, charsRemaining: $charsRemaining)
          }
          .task {
              await storeService.loadProducts()
              try? await Task.sleep(nanoseconds: 400_000_000)
              // Generate opening message from AI based on questionnaire context
              let openingMsg = ChatMessage(role: "assistant", content: "")
              messages.append(openingMsg)
              let msgId = openingMsg.id
              isStreaming = true
              var accumulated = ""
              let triggerPrompt = "请根据来访者的背景信息，用温暖直接的方式开始对话。不要问「你愿意分享吗」，直接切入他们的状态。可以对他们选择的内容做出有深度的回应，帮助他们感到被理解。"
              do {
                  try await DeepSeekService.streamChat(
                      messages: [ChatMessage(role: "user", content: triggerPrompt)],
                      systemPrompt: systemPrompt
                  ) { delta in
                      accumulated += delta
                      DispatchQueue.main.async {
                          if let idx = self.messages.firstIndex(where: { $0.id == msgId }) {
                              self.messages[idx] = ChatMessage(role: "assistant", content: accumulated, id: msgId)
                          }
                      }
                  }
              } catch {
                  if let idx = messages.firstIndex(where: { $0.id == msgId }) {
                      messages[idx] = ChatMessage(role: "assistant", content: opener, id: msgId)
                  }
              }
              isStreaming = false
          }
        }
    }

    // MARK: - Input bar

    private var inputBar: some View {
        let exhausted = charsRemaining == 0
        return HStack(spacing: 12) {
            TextField(exhausted ? "对话次数已用完" : "轻轻诉说你的想法...", text: $inputText, axis: .vertical)
                .foregroundStyle(exhausted ? Color.white.opacity(0.30) : Color.white)
                .font(.system(size: 15, weight: .light))
                .lineLimit(1...4)
                .padding(14)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.12)))
                .disabled(exhausted)

            Button {
                Task { await sendMessage() }
            } label: {
                Image(systemName: isStreaming ? "stop.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(inputText.isEmpty && !isStreaming ? Color.white.opacity(0.20) : Color.white)
            }
            .disabled(inputText.isEmpty && !isStreaming || exhausted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: 0x0A0A0A))
    }

    // MARK: - Quota warning banner

    private var quotaBanner: some View {
        let exhausted = charsRemaining == 0
        return HStack(spacing: 10) {
            Image(systemName: exhausted ? "lock.fill" : "exclamationmark.circle")
                .font(.system(size: 13))
                .foregroundStyle(exhausted ? Color(hex: 0xFF6B6B) : Color(hex: 0xFFD166))

            Text(exhausted
                 ? "免费对话次数已用完"
                 : "对话额度即将用完")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(exhausted ? Color(hex: 0xFF6B6B) : Color(hex: 0xFFD166))

            Spacer()

            Button {
                showPurchaseSheet = true
            } label: {
                Text("获取更多")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(exhausted ? Color(hex: 0xFF6B6B) : Color(hex: 0xFFD166))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            (exhausted ? Color(hex: 0xFF6B6B) : Color(hex: 0xFFD166)).opacity(0.08)
        )
    }

    private var background: some View {
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

    // MARK: - Send

    private var systemPrompt: String {
        let role: String
        switch categoryId {
        case "guilt":    role = "用户正在经历感情中的愧疚感，他们觉得自己可能出轨或越界了。"
        case "complex":  role = "用户的感情关系变得复杂，他们不知道该如何处理现在的局面。"
        case "occurred": role = "用户觉得某些事情已经发生了，他们想弄清楚自己真正的想法和感受。"
        default:         role = "用户正在经历感情困扰，需要整理思路。"
        }

        // Inject checklist context if available
        let record = store.record
        let entryType = record?.entryType ?? ""
        let results = record?.results ?? [:]
        let selectedOptions = store.selectedOptions
        let allQuestions = entryType == "self" ? kSelfQuestions : kPartnerQuestions
        let flaggedQuestions = allQuestions.filter { results[String($0.id)] == "flagged" }

        let checklistContext: String
        if flaggedQuestions.isEmpty {
            checklistContext = ""
        } else {
            let list = flaggedQuestions.map { q -> String in
                let itemId = String(q.id)
                if let chosen = selectedOptions[itemId] {
                    return "- \(q.title) → 用户选择了「\(chosen)」"
                } else {
                    return "- \(q.title) → 用户标记了「是」"
                }
            }.joined(separator: "\n")
            checklistContext = entryType == "self"
                ? "\n\n【用户自我审视结果】用户完成了一份关系自评问卷，以下是他们有共鸣的部分：\n\(list)"
                : "\n\n【用户排查结果】用户标记了伴侣存在以下异常行为：\n\(list)"
        }

        return """
        你是一位有执照的心理咨询师，擅长亲密关系与情感议题。你的风格温暖、不评判、直接。

        【当前来访者情况】
        \(role)\(checklistContext)

        【对话原则】
        1. 你已掌握来访者的背景信息，无需询问"你愿意分享吗"，直接进入实质对话。
        2. 来访者问"我选了哪些"或"你看到了什么"时，原文列出具体内容，再给出你的专业解读。
        3. 回复长度根据情境决定：简单回应1-2句即可，深度分析可以更长，但始终聚焦核心、不说废话。
        4. 不要每次都以问句结尾。大多数回复应以陈述或观察结束，只在真正需要推进对话时才提问，且每次最多一个问题。
        5. 只用中文回复。
        """
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
            try await DeepSeekService.streamChat(messages: messages.dropLast(), systemPrompt: systemPrompt) { delta in
                accumulated += delta
                DispatchQueue.main.async {
                    if let idx = self.messages.firstIndex(where: { $0.id == msgId }) {
                        self.messages[idx] = ChatMessage(role: "assistant", content: accumulated, id: msgId)
                    }
                }
            }
        } catch {
            if let idx = messages.firstIndex(where: { $0.id == msgId }) {
                messages[idx] = ChatMessage(role: "assistant", content: "网络异常，请重试。(\(error.localizedDescription))", id: msgId)
            }
        }
        isStreaming = false

        // Deduct quota: user input + AI response, update UI state
        if !accumulated.isEmpty {
            charsRemaining = QuotaService.deduct(text.count + accumulated.count)
        }
    }
}
