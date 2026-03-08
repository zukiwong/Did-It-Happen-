import Foundation
import CryptoKit
import CommonCrypto

/// Matches Flutter's EncryptionService exactly:
///   - Record ID:  SHA-256(passphrase.trim()) → lowercase hex
///   - Key:        PBKDF2-SHA256(passphrase.trim(), salt="chulemav1", iter=100000, keyLen=32)
///   - Payload:    base64( IV(12) + AES-256-GCM(ciphertext + 16-byte tag) )
enum EncryptionService {
    private static let pbkdf2Salt       = "chulemav1"
    private static let pbkdf2Iterations = 100_000
    private static let keyLength        = 32  // AES-256
    private static let ivLength         = 12  // GCM nonce

    // MARK: - Public API

    static func deriveRecordId(_ passphrase: String) -> String {
        let data   = Data(passphrase.trimmingCharacters(in: .whitespaces).utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// Encrypts plaintext string → base64(IV + ciphertext + tag)
    static func encrypt(_ passphrase: String, _ plaintext: String) throws -> String {
        let key  = try deriveKey(passphrase)
        let data = Data(plaintext.utf8)
        let encrypted = try encryptBytes(key: key, data: data)
        return encrypted.base64EncodedString()
    }

    /// Decrypts base64(IV + ciphertext + tag) → plaintext string
    static func decrypt(_ passphrase: String, _ encryptedBase64: String) throws -> String {
        guard let combined = Data(base64Encoded: encryptedBase64) else {
            throw EncryptionError.invalidBase64
        }
        let key       = try deriveKey(passphrase)
        let decrypted = try decryptBytes(key: key, combined: combined)
        guard let plaintext = String(data: decrypted, encoding: .utf8) else {
            throw EncryptionError.invalidUTF8
        }
        return plaintext
    }

    /// Encrypts raw Data → Data(IV + ciphertext + tag)
    static func encryptBytes(_ passphrase: String, _ data: Data) throws -> Data {
        let key = try deriveKey(passphrase)
        return try encryptBytes(key: key, data: data)
    }

    /// Decrypts Data(IV + ciphertext + tag) → raw Data
    static func decryptBytes(_ passphrase: String, _ combined: Data) throws -> Data {
        let key = try deriveKey(passphrase)
        return try decryptBytes(key: key, combined: combined)
    }

    // MARK: - Private

    private static func deriveKey(_ passphrase: String) throws -> SymmetricKey {
        let passData = Data(passphrase.trimmingCharacters(in: .whitespaces).utf8)
        let saltData = Data(pbkdf2Salt.utf8)

        var derivedKey = [UInt8](repeating: 0, count: keyLength)
        let result = passData.withUnsafeBytes { passPtr in
            saltData.withUnsafeBytes { saltPtr in
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    passPtr.baseAddress, passData.count,
                    saltPtr.baseAddress, saltData.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                    UInt32(pbkdf2Iterations),
                    &derivedKey, keyLength
                )
            }
        }
        guard result == kCCSuccess else { throw EncryptionError.keyDerivationFailed }
        return SymmetricKey(data: Data(derivedKey))
    }

    private static func encryptBytes(key: SymmetricKey, data: Data) throws -> Data {
        let nonce  = AES.GCM.Nonce()
        let sealed = try AES.GCM.seal(data, using: key, nonce: nonce)

        // Layout: IV(12) + ciphertext + tag(16) — matches Flutter/PointyCastle output
        var combined = Data()
        combined.append(contentsOf: nonce)
        combined.append(sealed.ciphertext)
        combined.append(sealed.tag)
        return combined
    }

    private static func decryptBytes(key: SymmetricKey, combined: Data) throws -> Data {
        guard combined.count > ivLength + 16 else { throw EncryptionError.tooShort }

        let nonce      = try AES.GCM.Nonce(data: combined.prefix(ivLength))
        let tagStart   = combined.count - 16
        let ciphertext = combined[ivLength..<tagStart]
        let tag        = combined[tagStart...]

        let sealed = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)
        return try AES.GCM.open(sealed, using: key)
    }
}

enum EncryptionError: Error {
    case keyDerivationFailed
    case invalidBase64
    case invalidUTF8
    case tooShort
}
