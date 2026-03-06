import Foundation

// MARK: - Investigation Record

struct InvestigationRecord: Codable {
    let entryType: String            // "partner" | "self"
    let completedAt: Date
    var results: [String: String]            // itemId → "flagged"|"normal"
    var evidences: [String: [String]]        // itemId → [storageFileKey]

    enum CodingKeys: String, CodingKey {
        case entryType   = "entry_type"
        case completedAt = "completed_at"
        case results
        case evidences
    }

    init(entryType: String,
         completedAt: Date = .now,
         results: [String: String] = [:],
         evidences: [String: [String]] = [:]) {
        self.entryType   = entryType
        self.completedAt = completedAt
        self.results     = results
        self.evidences   = evidences
    }
}

// MARK: - Pending File (staged before passphrase is known)

struct PendingFile: Identifiable {
    let id     = UUID()
    let itemId : String   // question id as string
    let url    : URL      // local temp file URL
}

// MARK: - Upload result

enum EvidenceUploadResult {
    case success(fileKey: String)
    case failure(String)
}

// MARK: - Save status

enum SaveStatus {
    case success
    case passphraseConflict
    case networkError
}

// MARK: - User path choice

enum UserChoice {
    case partner   // "查找出轨证据"
    case `self`    // "我是否出轨了"
    case records   // "查看历史记录"
}
