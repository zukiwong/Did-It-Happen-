import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

/// End-to-end encryption service.
///
/// Flow:
///   passphrase → SHA-256 → record ID (used to identify the row in Supabase)
///   passphrase → PBKDF2(SHA-256, 100000 iterations) → 32-byte AES key
///   AES-256-GCM(key, random 12-byte IV) → encrypted payload (base64)
class EncryptionService {
  static const _pbkdf2Salt = 'chulemav1'; // app-specific salt, not secret
  static const _pbkdf2Iterations = 100000;
  static const _keyLength = 32; // AES-256
  static const _ivLength = 12;  // GCM standard

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Encrypts raw [data] bytes using AES-256-GCM.
  /// Returns bytes: IV (12) + ciphertext + auth tag.
  static Uint8List encryptBytes(String passphrase, Uint8List data) {
    final key = _deriveKey(passphrase);
    final iv  = _randomBytes(_ivLength);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)),
      );

    final output   = cipher.process(data);
    final combined = Uint8List(_ivLength + output.length);
    combined.setRange(0, _ivLength, iv);
    combined.setRange(_ivLength, combined.length, output);
    return combined;
  }

  /// Decrypts bytes produced by [encryptBytes].
  static Uint8List decryptBytes(String passphrase, Uint8List combined) {
    final key        = _deriveKey(passphrase);
    final iv         = combined.sublist(0, _ivLength);
    final ciphertext = combined.sublist(_ivLength);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)),
      );

    return cipher.process(Uint8List.fromList(ciphertext));
  }

  /// Derives the Supabase record ID from the passphrase.
  /// This is SHA-256(passphrase) as a hex string.
  static String deriveRecordId(String passphrase) {
    final bytes = utf8.encode(passphrase.trim());
    return sha256.convert(bytes).toString();
  }

  /// Encrypts [plaintext] using AES-256-GCM with a key derived from [passphrase].
  /// Returns a base64-encoded string: base64(IV + ciphertext + authTag).
  static String encrypt(String passphrase, String plaintext) {
    final key = _deriveKey(passphrase);
    final iv  = _randomBytes(_ivLength);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true, // encrypt
        AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)),
      );

    final input  = Uint8List.fromList(utf8.encode(plaintext));
    final output = cipher.process(input);

    // Prepend IV so we can recover it during decryption
    final combined = Uint8List(_ivLength + output.length);
    combined.setRange(0, _ivLength, iv);
    combined.setRange(_ivLength, combined.length, output);

    return base64.encode(combined);
  }

  /// Decrypts a payload produced by [encrypt].
  /// Returns the original plaintext string, or throws on bad passphrase / tampered data.
  static String decrypt(String passphrase, String encryptedBase64) {
    final key      = _deriveKey(passphrase);
    final combined = base64.decode(encryptedBase64);

    final iv         = combined.sublist(0, _ivLength);
    final ciphertext = combined.sublist(_ivLength);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false, // decrypt
        AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)),
      );

    final decrypted = cipher.process(Uint8List.fromList(ciphertext));
    return utf8.decode(decrypted);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static Uint8List _deriveKey(String passphrase) {
    final saltBytes  = utf8.encode(_pbkdf2Salt);
    final passBytes  = utf8.encode(passphrase.trim());

    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(
        Uint8List.fromList(saltBytes),
        _pbkdf2Iterations,
        _keyLength,
      ));

    return pbkdf2.process(Uint8List.fromList(passBytes));
  }

  static Uint8List _randomBytes(int length) {
    final rng   = Random.secure();
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = rng.nextInt(256);
    }
    return bytes;
  }
}
