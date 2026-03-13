import Foundation

// MARK: - DeepSeek streaming chat service (proxied via Supabase Edge Function)

struct ChatMessage: Identifiable {
    let id     : UUID
    let role   : String   // "user" | "assistant"
    let content: String

    init(role: String, content: String, id: UUID = UUID()) {
        self.id      = id
        self.role    = role
        self.content = content
    }
}

enum DeepSeekService {
    private static let endpoint = URL(string: "\(supabaseURL)/functions/v1/deepseek-chat")!

    /// Streams a response token by token. Yields each delta string.
    static func streamChat(
        messages: [ChatMessage],
        systemPrompt prompt: String,
        onDelta: @escaping (String) -> Void
    ) async throws {
        let body: [String: Any] = [
            "systemPrompt": prompt,
            "messages": messages.map { ["role": $0.role, "content": $0.content] }
        ]

        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        print("[DeepSeek] sending to \(endpoint)")
        let (bytes, response) = try await URLSession.shared.bytes(for: req)
        if let http = response as? HTTPURLResponse {
            print("[DeepSeek] HTTP status: \(http.statusCode)")
        }
        for try await line in bytes.lines {
            print("[DeepSeek] line: \(line)")
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
