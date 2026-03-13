import Foundation

// MARK: - Remote question loading with local fallback

enum QuestionService {

    private static let baseURL = "https://glahtdyrlqurkwrujwxq.supabase.co/storage/v1/object/public/config"

    static func fetchSelfQuestions() async -> [QuestionItem] {
        await fetch(
            remoteURL: URL(string: "\(baseURL)/self_risk_questions.json")!,
            cacheKey:  "cached_self_risk_questions",
            fallback:  kSelfQuestions
        )
    }

    static func fetchPartnerQuestions() async -> [QuestionItem] {
        await fetch(
            remoteURL: URL(string: "\(baseURL)/partner_questions.json")!,
            cacheKey:  "cached_partner_questions",
            fallback:  kPartnerQuestions
        )
    }

    // MARK: - Core

    private static func fetch(remoteURL: URL, cacheKey: String, fallback: [QuestionItem]) async -> [QuestionItem] {
        if let remote = await fetchRemote(url: remoteURL) {
            persist(remote, key: cacheKey)
            return remote
        }
        if let cached = loadCached(key: cacheKey) {
            return cached
        }
        return fallback
    }

    // MARK: - Private

    private static func fetchRemote(url: URL) async -> [QuestionItem]? {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "t", value: "\(Int(Date().timeIntervalSince1970 / 3600))")]
        guard let bustedURL = components.url,
              let (data, response) = try? await URLSession.shared.data(from: bustedURL),
              (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
        return decode(data)
    }

    private static func decode(_ data: Data) -> [QuestionItem]? {
        struct Payload: Decodable {
            struct Q: Decodable {
                let id: Int
                let category: String
                let title: String
                let subtitle: String?
                let points: [String]
                let tip: String?
            }
            let questions: [Q]
        }
        guard let payload = try? JSONDecoder().decode(Payload.self, from: data) else { return nil }
        return payload.questions.map {
            QuestionItem(id: $0.id, category: $0.category, title: $0.title,
                         subtitle: $0.subtitle, points: $0.points, tip: $0.tip)
        }
    }

    private static func persist(_ items: [QuestionItem], key: String) {
        struct Storable: Codable {
            let id: Int; let category: String; let title: String
            let subtitle: String?; let points: [String]; let tip: String?
        }
        let storables = items.map { Storable(id: $0.id, category: $0.category, title: $0.title,
                                              subtitle: $0.subtitle, points: $0.points, tip: $0.tip) }
        if let data = try? JSONEncoder().encode(storables) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private static func loadCached(key: String) -> [QuestionItem]? {
        struct Storable: Codable {
            let id: Int; let category: String; let title: String
            let subtitle: String?; let points: [String]; let tip: String?
        }
        guard let data = UserDefaults.standard.data(forKey: key),
              let storables = try? JSONDecoder().decode([Storable].self, from: data) else { return nil }
        return storables.map {
            QuestionItem(id: $0.id, category: $0.category, title: $0.title,
                         subtitle: $0.subtitle, points: $0.points, tip: $0.tip)
        }
    }
}
