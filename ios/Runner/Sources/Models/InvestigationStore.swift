import Foundation
import Observation

@Observable
class InvestigationStore {
    var passphrase      : String?
    var record          : InvestigationRecord?
    var pendingFiles    : [PendingFile] = []
    var isBusy          = false
    var error           : String?
    var selectedOptions : [String: String] = [:]   // itemId → selected point text

    // MARK: - Session setup

    func startSession(entryType: String) {
        passphrase   = nil
        pendingFiles = []
        error        = nil
        record = InvestigationRecord(entryType: entryType)
    }

    func setPassphrase(_ value: String) {
        passphrase = value
        error = nil
    }

    // MARK: - Checklist mutations

    func markResult(itemId: String, status: String) {
        record?.results[itemId] = status
    }

    func stagePendingFile(itemId: String, url: URL) {
        pendingFiles.append(PendingFile(itemId: itemId, url: url))
    }

    func clearPendingFiles() {
        pendingFiles = []
    }

    func addEvidenceKey(itemId: String, fileKey: String) {
        if record?.evidences[itemId] == nil {
            record?.evidences[itemId] = []
        }
        record?.evidences[itemId]?.append(fileKey)
        // Update completedAt to now on each evidence addition
        if let r = record {
            record = InvestigationRecord(
                entryType:   r.entryType,
                completedAt: .now,
                results:     r.results,
                evidences:   r.evidences
            )
        }
    }

    // MARK: - Persistence

    @discardableResult
    func save() async -> SaveStatus {
        guard let passphrase, !passphrase.isEmpty else { return .networkError }
        guard let record else { return .networkError }
        isBusy = true
        let status = await InvestigationStorageService.save(passphrase: passphrase, record: record)
        isBusy = false
        if status != .success {
            error = status == .passphraseConflict
                ? "该密钥已被其他档案使用"
                : "保存失败，请检查网络连接"
        }
        return status
    }

    func load(passphrase: String) async -> Bool {
        isBusy = true
        let loaded = await InvestigationStorageService.load(passphrase: passphrase)
        isBusy = false
        if let loaded {
            self.passphrase = passphrase
            self.record     = loaded
            return true
        } else {
            error = "密钥错误或未找到记录"
            return false
        }
    }

    func recordSelectedOption(itemId: String, point: String) {
        selectedOptions[itemId] = point
    }

    func clear() {
        passphrase      = nil
        record          = nil
        pendingFiles    = []
        isBusy          = false
        error           = nil
        selectedOptions = [:]
    }

    // MARK: - Computed helpers

    var totalEvidenceCount: Int {
        let uploaded = record?.evidences.values.reduce(0) { $0 + $1.count } ?? 0
        return uploaded + pendingFiles.count
    }

    var isEvidenceFull: Bool {
        totalEvidenceCount >= EvidenceService.maxTotalEvidenceFiles
    }

    var isFlagged: (String) -> Bool {
        { [self] itemId in
            record?.results[itemId] == "flagged" ||
            pendingFiles.contains { $0.itemId == itemId }
        }
    }
}
