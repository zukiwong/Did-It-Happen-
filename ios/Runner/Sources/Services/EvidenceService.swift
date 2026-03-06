import Foundation
import AVFoundation
import PhotosUI

// MARK: - Evidence Service

enum EvidenceService {
    private static let bucket = "evidence-files"
    private static var audioRecorder: AVAudioRecorder?
    private static var currentRecordingURL: URL?

    // MARK: - Upload

    static func uploadEvidence(url: URL, passphrase: String, itemId: String) async -> EvidenceUploadResult {
        do {
            let data      = try Data(contentsOf: url)
            let encrypted = try EncryptionService.encryptBytes(passphrase, data)

            let recordId  = EncryptionService.deriveRecordId(passphrase)
            let uid       = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            let origExt   = url.pathExtension.lowercased() == "m4a" ? ".m4a" : ".jpg"
            let fileKey   = "\(recordId.prefix(8))_\(itemId)_\(uid)\(origExt).enc"

            try await SupabaseService.shared.uploadFile(key: fileKey, data: encrypted)
            return .success(fileKey: fileKey)
        } catch {
            return .failure(error.localizedDescription)
        }
    }

    // MARK: - Download

    static func downloadEvidence(fileKey: String, passphrase: String) async -> Data? {
        do {
            let encrypted = try await SupabaseService.shared.downloadFile(key: fileKey)
            return try EncryptionService.decryptBytes(passphrase, encrypted)
        } catch {
            return nil
        }
    }

    // MARK: - Audio recording

    static func startRecording() async -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch { return false }

        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("evidence_\(UUID().uuidString).m4a")

        let settings: [String: Any] = [
            AVFormatIDKey:         Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey:       44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitRateKey:   128_000,
        ]

        guard let recorder = try? AVAudioRecorder(url: tmpURL, settings: settings) else { return false }
        recorder.record()
        audioRecorder        = recorder
        currentRecordingURL  = tmpURL
        return true
    }

    static func stopRecording() -> URL? {
        audioRecorder?.stop()
        audioRecorder = nil
        let url = currentRecordingURL
        currentRecordingURL = nil
        return url
    }

    static func cancelRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        if let url = currentRecordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        currentRecordingURL = nil
    }
}
