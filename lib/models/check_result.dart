import 'checklist_item.dart';

enum RiskLevel { low, mid, high }

/// The computed result of a completed checklist session.
class CheckResult {
  final String entryType; // 'partner' | 'self'
  final List<ChecklistItem> flagged; // answered "yes / abnormal"
  final List<ChecklistItem> passed;  // answered "no / normal"
  final DateTime createdAt;

  const CheckResult({
    required this.entryType,
    required this.flagged,
    required this.passed,
    required this.createdAt,
  });

  int get flaggedCount => flagged.length;
  int get totalCount => flagged.length + passed.length;

  RiskLevel get riskLevel {
    if (flaggedCount <= 2) return RiskLevel.low;
    if (flaggedCount <= 5) return RiskLevel.mid;
    return RiskLevel.high;
  }

  String get riskLabel {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'No significant signals detected';
      case RiskLevel.mid:
        return 'Anomalous signals present';
      case RiskLevel.high:
        return 'Multiple anomalous signals';
    }
  }
}
