import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'encryption_service.dart';

/// Result of an evidence upload attempt.
class EvidenceUploadResult {
  final bool success;
  final String? fileKey;   // Storage path to reference from InvestigationRecord
  final String? error;

  const EvidenceUploadResult.ok(this.fileKey)
      : success = true,
        error = null;

  const EvidenceUploadResult.fail(this.error)
      : success = false,
        fileKey = null;
}

/// Handles evidence file picking, audio recording, encryption, and upload.
///
/// All files are AES-256-GCM encrypted (client-side) before upload.
/// Bucket: evidence-files
class EvidenceService {
  static const _bucket = 'evidence-files';
  static final _picker  = ImagePicker();
  static const _uuid    = Uuid();

  // Singleton recorder — kept alive between start/stop calls
  static final _recorder = AudioRecorder();

  // ── Pick ──────────────────────────────────────────────────────

  /// Opens the camera and returns the captured image file.
  static Future<File?> pickFromCamera() async {
    final xFile = await _picker.pickImage(
      source:       ImageSource.camera,
      imageQuality: 80,
      preferredCameraDevice: CameraDevice.rear,
    );
    return xFile == null ? null : File(xFile.path);
  }

  /// Opens the photo gallery and returns the selected image file.
  static Future<File?> pickFromGallery() async {
    final xFile = await _picker.pickImage(
      source:       ImageSource.gallery,
      imageQuality: 80,
    );
    return xFile == null ? null : File(xFile.path);
  }

  // ── Recording ─────────────────────────────────────────────────

  /// Returns true if the recorder is currently active.
  static Future<bool> get isRecording => _recorder.isRecording();

  /// Starts recording to a temp m4a file.
  /// Call [stopRecording] to finish and get the file.
  static Future<bool> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return false;

    final dir  = await getTemporaryDirectory();
    final path = '${dir.path}/evidence_${_uuid.v4()}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder:    AudioEncoder.aacLc,
        bitRate:    128000,
        sampleRate: 44100,
      ),
      path: path,
    );
    return true;
  }

  /// Stops recording and returns the saved m4a file (or null on failure).
  static Future<File?> stopRecording() async {
    final path = await _recorder.stop();
    if (path == null) return null;
    return File(path);
  }

  /// Cancels an in-progress recording without saving.
  static Future<void> cancelRecording() async {
    await _recorder.cancel();
  }

  // ── Upload ────────────────────────────────────────────────────

  /// Encrypts [file] with [passphrase] and uploads to Supabase Storage.
  ///
  /// [itemId] is the checklist question id (e.g. '1', '5').
  /// Returns the storage path (fileKey) on success.
  static Future<EvidenceUploadResult> uploadEvidence({
    required File file,
    required String passphrase,
    required String itemId,
  }) async {
    try {
      final bytes     = await file.readAsBytes();
      final encrypted = EncryptionService.encryptBytes(passphrase, bytes);

      final recordId  = EncryptionService.deriveRecordId(passphrase);
      final uid       = _uuid.v4().replaceAll('-', '');
      // Preserve original extension before .enc so type can be inferred later
      final origExt   = file.path.contains('.m4a') ? '.m4a' : '.jpg';
      final fileKey   = '${recordId.substring(0, 8)}_${itemId}_$uid$origExt.enc';

      await Supabase.instance.client.storage
          .from(_bucket)
          .uploadBinary(
            fileKey,
            encrypted,
            fileOptions: const FileOptions(upsert: false),
          );

      return EvidenceUploadResult.ok(fileKey);
    } catch (e) {
      return EvidenceUploadResult.fail(e.toString());
    }
  }

  // ── Download ──────────────────────────────────────────────────

  /// Downloads and decrypts an evidence file by its [fileKey].
  static Future<Uint8List?> downloadEvidence({
    required String fileKey,
    required String passphrase,
  }) async {
    try {
      final encrypted = await Supabase.instance.client.storage
          .from(_bucket)
          .download(fileKey);
      return EncryptionService.decryptBytes(passphrase, encrypted);
    } catch (_) {
      return null;
    }
  }
}
