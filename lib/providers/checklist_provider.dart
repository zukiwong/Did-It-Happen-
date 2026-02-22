import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/checklist_data.dart';
import '../models/checklist_item.dart';
import '../models/check_result.dart';

/// Which entry point the user chose.
final entryTypeProvider = StateProvider<String>((ref) => 'partner');

/// Map of item id → whether it was flagged (true = abnormal).
class ChecklistNotifier extends StateNotifier<Map<String, bool>> {
  ChecklistNotifier() : super({});

  void toggle(String id, bool flagged) {
    state = {...state, id: flagged};
  }

  void reset() {
    state = {};
  }

  CheckResult buildResult(String entryType) {
    final flagged = <ChecklistItem>[];
    final passed = <ChecklistItem>[];

    for (final item in kChecklistItems) {
      final isFlagged = state[item.id] ?? false;
      if (isFlagged) {
        flagged.add(item);
      } else {
        passed.add(item);
      }
    }

    return CheckResult(
      entryType: entryType,
      flagged: flagged,
      passed: passed,
      createdAt: DateTime.now(),
    );
  }
}

final checklistProvider =
    StateNotifierProvider<ChecklistNotifier, Map<String, bool>>(
  (ref) => ChecklistNotifier(),
);

/// The final result — set after user completes all phases.
final checkResultProvider = StateProvider<CheckResult?>((ref) => null);
