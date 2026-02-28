import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'encryption_service.dart';

/// Result of a save attempt.
enum SaveStatus { success, passphraseConflict, networkError }

/// Result of a load attempt.
class LoadResult {
  final bool found;
  final InvestigationRecord? record;
  final String? error;
  const LoadResult({required this.found, this.record, this.error});
}

/// A decrypted investigation record.
class InvestigationRecord {
  final String entryType;
  final DateTime completedAt;
  final Map<String, String> results;   // itemId → 'flagged'|'normal'|'skipped'
  final Map<String, List<String>> evidences; // itemId → list of storage file keys

  const InvestigationRecord({
    required this.entryType,
    required this.completedAt,
    required this.results,
    required this.evidences,
  });

  factory InvestigationRecord.fromJson(Map<String, dynamic> json) {
    final rawResults   = json['results']   as Map<String, dynamic>? ?? {};
    final rawEvidences = json['evidences'] as Map<String, dynamic>? ?? {};

    return InvestigationRecord(
      entryType:   json['entry_type'] as String,
      completedAt: DateTime.parse(json['completed_at'] as String),
      results:     rawResults.map((k, v) => MapEntry(k, v as String)),
      evidences:   rawEvidences.map(
        (k, v) => MapEntry(k, List<String>.from(v as List)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'entry_type':   entryType,
    'completed_at': completedAt.toIso8601String(),
    'results':      results,
    'evidences':    evidences,
  };

}

/// Handles saving and loading encrypted investigation records to Supabase.
class InvestigationStorageService {
  static final _client = Supabase.instance.client;
  static const _table  = 'investigation_records';

  /// Save an investigation record encrypted with [passphrase].
  ///
  /// Returns [SaveStatus.passphraseConflict] if the derived ID already exists
  /// (meaning someone else — or the same user — used that passphrase before).
  static Future<SaveStatus> save({
    required String passphrase,
    required InvestigationRecord record,
  }) async {
    try {
      final id      = EncryptionService.deriveRecordId(passphrase);
      final payload = EncryptionService.encrypt(
        passphrase,
        jsonEncode(record.toJson()),
      );

      // Try insert; if id already exists, try update to allow re-saving same session
      final existing = await _client
          .from(_table)
          .select('id')
          .eq('id', id)
          .maybeSingle();

      if (existing != null) {
        // ID exists — update (user re-saving with same passphrase = OK)
        await _client
            .from(_table)
            .update({'payload': payload})
            .eq('id', id);
      } else {
        await _client.from(_table).insert({'id': id, 'payload': payload});
      }

      return SaveStatus.success;
    } on PostgrestException catch (e) {
      // Unique violation on id (race condition)
      if (e.code == '23505') return SaveStatus.passphraseConflict;
      return SaveStatus.networkError;
    } catch (_) {
      return SaveStatus.networkError;
    }
  }

  /// Load and decrypt a record by [passphrase].
  static Future<LoadResult> load({required String passphrase}) async {
    try {
      final id = EncryptionService.deriveRecordId(passphrase);
      final row = await _client
          .from(_table)
          .select('payload')
          .eq('id', id)
          .maybeSingle();

      if (row == null) {
        return const LoadResult(found: false);
      }

      final plaintext = EncryptionService.decrypt(passphrase, row['payload'] as String);
      final json      = jsonDecode(plaintext) as Map<String, dynamic>;
      final record    = InvestigationRecord.fromJson(json);
      return LoadResult(found: true, record: record);
    } catch (_) {
      return const LoadResult(found: false, error: 'Decryption failed or record not found.');
    }
  }

  /// Add an evidence file key to a specific item in an existing record.
  /// Re-fetches, decrypts, appends, re-encrypts, then updates.
  static Future<bool> addEvidence({
    required String passphrase,
    required String itemId,
    required String fileKey,
  }) async {
    try {
      final result = await load(passphrase: passphrase);
      if (!result.found || result.record == null) return false;

      final record    = result.record!;
      final evidences = Map<String, List<String>>.from(record.evidences);
      evidences[itemId] = [...(evidences[itemId] ?? []), fileKey];

      final updated = InvestigationRecord(
        entryType:   record.entryType,
        completedAt: record.completedAt,
        results:     record.results,
        evidences:   evidences,
      );

      final status = await save(passphrase: passphrase, record: updated);
      return status == SaveStatus.success;
    } catch (_) {
      return false;
    }
  }
}
