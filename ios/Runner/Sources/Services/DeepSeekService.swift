import Foundation

// MARK: - DeepSeek streaming chat service

struct ChatMessage: Identifiable {
    let id      = UUID()
    let role    : String   // "user" | "assistant"
    let content : String
}

enum DeepSeekService {
    private static let endpoint = URL(string: "https://api.deepseek.com/chat/completions")!

    private static let systemPrompt = """
    你是一位专业的情感支持顾问，擅长帮助用户梳理情感困惑、分析关系问题。\
    你的回答应当温暖、理性、不评判，引导用户思考自己真实的感受和需求。\
    请使用简洁的中文回复，避免使用过多专业术语。
    """

    /// Streams a response token by token. Yields each delta string.
    static func streamChat(
        messages: [ChatMessage],
        onDelta: @escaping (String) -> Void
    ) async throws {
        let body: [String: Any] = [
            "model":  "deepseek-chat",
            "stream": true,
            "messages": [["role": "system", "content": systemPrompt]] +
                messages.map { ["role": $0.role, "content": $0.content] }
        ]

        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("Bearer \(deepSeekAPIKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (bytes, _) = try await URLSession.shared.bytes(for: req)
        for try await line in bytes.lines {
            guard line.hasPrefix("data: "),
                  let data = line.dropFirst(6).data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let delta = choices.first?["delta"] as? [String: Any],
                  let text = delta["content"] as? String
            else { continue }
            onDelta(text)
        }
    }
}
