/// A single checklist question.
class ChecklistItem {
  final String id;
  final int phase; // 1 = list, 2 = behavior (one per page), 3 = values (one per page)
  final String category;
  final String question;
  final String? detail; // optional sub-text shown on phase 2/3 pages

  const ChecklistItem({
    required this.id,
    required this.phase,
    required this.category,
    required this.question,
    this.detail,
  });
}
