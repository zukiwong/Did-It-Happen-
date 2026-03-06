import Foundation

// MARK: - Supabase HTTP client (no SDK dependency, uses URLSession)

/// Thin wrapper around Supabase REST + Storage APIs.
/// Uses URLSession directly so we avoid adding a Swift package dependency.
actor SupabaseService {
    static let shared = SupabaseService()
    private init() {}

    private let restBase    = "\(supabaseURL)/rest/v1"
    private let storageBase = "\(supabaseURL)/storage/v1"
    private let table       = "investigation_records"
    private let bucket      = "evidence-files"

    // MARK: - Record save/load

    func saveRecord(id: String, payload: String) async throws {
        // Check if exists first
        let existing = try await fetchRow(id: id)
        if existing != nil {
            try await updateRow(id: id, payload: payload)
        } else {
            try await insertRow(id: id, payload: payload)
        }
    }

    func loadRecord(id: String) async throws -> String? {
        guard let row = try await fetchRow(id: id) else { return nil }
        return row["payload"] as? String
    }

    // MARK: - Storage upload/download

    func uploadFile(key: String, data: Data) async throws {
        let url = URL(string: "\(storageBase)/object/\(bucket)/\(key)")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        req.httpBody = data

        let (_, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw SupabaseError.uploadFailed
        }
    }

    func downloadFile(key: String) async throws -> Data {
        let url = URL(string: "\(storageBase)/object/\(bucket)/\(key)")!
        var req = URLRequest(url: url)
        req.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw SupabaseError.downloadFailed
        }
        return data
    }

    // MARK: - Private helpers

    private func fetchRow(id: String) async throws -> [String: Any]? {
        let url = URL(string: "\(restBase)/\(table)?id=eq.\(id)&select=payload&limit=1")!
        var req = URLRequest(url: url)
        req.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, _) = try await URLSession.shared.data(for: req)
        let rows = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
        return rows.first
    }

    private func insertRow(id: String, payload: String) async throws {
        let url = URL(string: "\(restBase)/\(table)")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: ["id": id, "payload": payload])

        let (_, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw SupabaseError.saveFailed
        }
    }

    private func updateRow(id: String, payload: String) async throws {
        let url = URL(string: "\(restBase)/\(table)?id=eq.\(id)")!
        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: ["payload": payload])

        let (_, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw SupabaseError.saveFailed
        }
    }
}

enum SupabaseError: Error {
    case saveFailed
    case uploadFailed
    case downloadFailed
}
