import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/investigation_storage_service.dart';

/// A file staged for upload, awaiting the passphrase to be set.
class PendingFile {
  final String itemId;
  final File file;
  const PendingFile({required this.itemId, required this.file});
}

// ── State ─────────────────────────────────────────────────────

class InvestigationState {
  /// The user's secret passphrase for this session.
  final String? passphrase;

  /// The in-memory investigation record being built or loaded.
  final InvestigationRecord? record;

  /// Whether a save/load operation is in progress.
  final bool isBusy;

  /// Last error message, null if none.
  final String? error;

  /// Files captured during checklist but not yet uploaded (no passphrase yet).
  final List<PendingFile> pendingFiles;

  const InvestigationState({
    this.passphrase,
    this.record,
    this.isBusy = false,
    this.error,
    this.pendingFiles = const [],
  });

  InvestigationState copyWith({
    String? passphrase,
    InvestigationRecord? record,
    bool? isBusy,
    String? error,
    bool clearError = false,
    bool clearRecord = false,
    List<PendingFile>? pendingFiles,
    bool clearPending = false,
  }) {
    return InvestigationState(
      passphrase: passphrase ?? this.passphrase,
      record: clearRecord ? null : (record ?? this.record),
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : (error ?? this.error),
      pendingFiles: clearPending ? const [] : (pendingFiles ?? this.pendingFiles),
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────

class InvestigationNotifier extends StateNotifier<InvestigationState> {
  InvestigationNotifier() : super(const InvestigationState());

  // ── Session setup ────────────────────────────────────────────

  /// Called when the user begins a new investigation (TA or self path).
  void startSession({required String entryType}) {
    state = InvestigationState(
      record: InvestigationRecord(
        entryType: entryType,
        completedAt: DateTime.now(),
        results: {},
        evidences: {},
      ),
    );
  }

  /// Sets the passphrase (from TraceReport key input or ArchiveAccess).
  void setPassphrase(String passphrase) {
    state = state.copyWith(passphrase: passphrase, clearError: true);
  }

  // ── In-progress record mutations ─────────────────────────────

  /// Marks a single checklist item as 'flagged' or 'normal'.
  void markResult(String itemId, String status) {
    final current = state.record;
    if (current == null) return;
    final updated = Map<String, String>.from(current.results)
      ..[itemId] = status;
    state = state.copyWith(
      record: InvestigationRecord(
        entryType:   current.entryType,
        completedAt: current.completedAt,
        results:     updated,
        evidences:   current.evidences,
      ),
    );
  }

  /// Stages a local file for later upload (when passphrase is not yet set).
  void stagePendingFile(String itemId, File file) {
    final updated = [...state.pendingFiles, PendingFile(itemId: itemId, file: file)];
    state = state.copyWith(pendingFiles: updated);
  }

  /// Clears the pending file queue after a successful batch upload.
  void clearPendingFiles() {
    state = state.copyWith(clearPending: true);
  }

  /// Adds a Storage file key to a specific item's evidence list.
  void addEvidenceKey(String itemId, String fileKey) {
    final current = state.record;
    if (current == null) return;
    final evidences = Map<String, List<String>>.from(current.evidences);
    evidences[itemId] = [...(evidences[itemId] ?? []), fileKey];
    state = state.copyWith(
      record: InvestigationRecord(
        entryType:   current.entryType,
        completedAt: DateTime.now(),
        results:     current.results,
        evidences:   evidences,
      ),
    );
  }

  // ── Persistence ───────────────────────────────────────────────

  /// Saves the current record encrypted with the current passphrase.
  /// Returns [SaveStatus]; sets error on failure.
  Future<SaveStatus> save() async {
    final passphrase = state.passphrase;
    final record     = state.record;
    if (passphrase == null || passphrase.isEmpty) {
      state = state.copyWith(error: 'No passphrase set.');
      return SaveStatus.networkError;
    }
    if (record == null) {
      state = state.copyWith(error: 'No investigation record to save.');
      return SaveStatus.networkError;
    }

    state = state.copyWith(isBusy: true, clearError: true);
    final status = await InvestigationStorageService.save(
      passphrase: passphrase,
      record: record,
    );
    state = state.copyWith(
      isBusy: false,
      error: status == SaveStatus.success ? null : _errorFor(status),
    );
    return status;
  }

  /// Loads and decrypts a record by passphrase.
  /// Returns true if found and decrypted successfully.
  Future<bool> load(String passphrase) async {
    state = state.copyWith(isBusy: true, clearError: true);
    final result = await InvestigationStorageService.load(
      passphrase: passphrase,
    );
    if (result.found && result.record != null) {
      state = state.copyWith(
        isBusy:     false,
        passphrase: passphrase,
        record:     result.record,
      );
      return true;
    } else {
      state = state.copyWith(
        isBusy: false,
        error:  'Incorrect key or no record found.',
        clearRecord: true,
      );
      return false;
    }
  }

  /// Clears the current session (e.g. on exit).
  void clear() {
    state = const InvestigationState();
  }

  // ── Helpers ───────────────────────────────────────────────────

  static String _errorFor(SaveStatus s) {
    switch (s) {
      case SaveStatus.success:
        return '';
      case SaveStatus.passphraseConflict:
        return 'This key is already in use by another record.';
      case SaveStatus.networkError:
        return 'Network error. Please try again.';
    }
  }
}

// ── Provider ──────────────────────────────────────────────────

final investigationProvider =
    StateNotifierProvider<InvestigationNotifier, InvestigationState>(
  (ref) => InvestigationNotifier(),
);
