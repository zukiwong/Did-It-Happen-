import Foundation
import AVFoundation
import PhotosUI
import UIKit

// MARK: - Evidence Service

enum EvidenceService {
    private static let bucket = "evidence-files"
    private static var audioRecorder: AVAudioRecorder?
    private static var currentRecordingURL: URL?

    // MARK: - Upload

    static func uploadEvidence(url: URL, passphrase: String, itemId: String) async -> EvidenceUploadResult {
        do {
            let raw  = try Data(contentsOf: url)
            // Compress images to ~300KB before encrypting; audio passes through as-is
            let isAudio = url.pathExtension.lowercased() == "m4a"
            let data    = isAudio ? raw : compressImage(raw, maxBytes: 300_000) ?? raw
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
            // .defaultToSpeaker routes audio through main mic (not earpiece mic)
            try session.setCategory(.playAndRecord, mode: .default,
                                    options: [.defaultToSpeaker, .allowBluetooth])
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
        recorder.isMeteringEnabled = true
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

    /// Returns normalized audio level 0.0–1.0 (0 = silence, 1 = loud).
    /// Call periodically while recording.
    static func audioLevel() -> Float {
        guard let r = audioRecorder, r.isRecording else { return 0 }
        r.updateMeters()
        // averagePower is in dB, typically -160 (silence) to 0 (max)
        let db    = r.averagePower(forChannel: 0)
        let floor : Float = -50   // treat anything quieter as silence
        let level = max(0, (db - floor) / (-floor))  // 0…1
        return min(level, 1)
    }

    // MARK: - Image compression

    private static func compressImage(_ data: Data, maxBytes: Int) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        // Scale down if larger than 1920px on longest side
        let maxDim: CGFloat = 1920
        let size = image.size
        let scale = min(maxDim / max(size.width, size.height), 1.0)
        let target: UIImage
        if scale < 1.0 {
            let newSize = CGSize(width: size.width * scale, height: size.height * scale)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            target = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        } else {
            target = image
        }
        // Binary search for the right JPEG quality
        var lo: CGFloat = 0.1, hi: CGFloat = 0.85
        var best = target.jpegData(compressionQuality: hi)
        for _ in 0..<6 {
            let mid = (lo + hi) / 2
            if let d = target.jpegData(compressionQuality: mid) {
                best = d
                if d.count <= maxBytes { lo = mid } else { hi = mid }
            }
        }
        return best
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
