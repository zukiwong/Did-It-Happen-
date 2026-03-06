import Foundation

enum InvestigationStorageService {
    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    // MARK: - Save

    static func save(passphrase: String, record: InvestigationRecord) async -> SaveStatus {
        do {
            let id      = EncryptionService.deriveRecordId(passphrase)
            let json    = try encoder.encode(record)
            let payload = try EncryptionService.encrypt(passphrase, String(data: json, encoding: .utf8)!)
            try await SupabaseService.shared.saveRecord(id: id, payload: payload)
            return .success
        } catch {
            return .networkError
        }
    }

    // MARK: - Load

    static func load(passphrase: String) async -> InvestigationRecord? {
        do {
            let id = EncryptionService.deriveRecordId(passphrase)
            guard let payload = try await SupabaseService.shared.loadRecord(id: id) else { return nil }
            let plaintext = try EncryptionService.decrypt(passphrase, payload)
            guard let data = plaintext.data(using: .utf8) else { return nil }
            return try decoder.decode(InvestigationRecord.self, from: data)
        } catch {
            return nil
        }
    }
}
