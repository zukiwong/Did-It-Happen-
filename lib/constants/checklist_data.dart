import '../models/checklist_item.dart';

/// All checklist questions, grouped by category.
/// Phase 1: list-style multi-select
/// Phase 2: single page per question (behavior verification)
/// Phase 3: single page per question (values / cognitive gap)

const List<ChecklistItem> kChecklistItems = [
  // ── Phase 1: Relationship signals (list) ────────────────────────
  ChecklistItem(
    id: 'c1',
    phase: 1,
    category: 'Communication',
    question: 'Has the frequency of your communication noticeably dropped?',
  ),
  ChecklistItem(
    id: 'c2',
    phase: 1,
    category: 'Communication',
    question: 'Are replies significantly slower than before?',
  ),
  ChecklistItem(
    id: 'c3',
    phase: 1,
    category: 'Communication',
    question: 'Have conversations become shorter or more surface-level?',
  ),
  ChecklistItem(
    id: 'c4',
    phase: 1,
    category: 'Emotion',
    question: 'Has their emotional state become noticeably more volatile?',
  ),
  ChecklistItem(
    id: 'c5',
    phase: 1,
    category: 'Emotion',
    question: 'Have they become more irritable or impatient toward you?',
  ),
  ChecklistItem(
    id: 'c6',
    phase: 1,
    category: 'Emotion',
    question: 'Do they seem distracted or emotionally absent?',
  ),
  ChecklistItem(
    id: 'c7',
    phase: 1,
    category: 'Social',
    question: 'Have they started protecting their phone more than usual?',
  ),
  ChecklistItem(
    id: 'c8',
    phase: 1,
    category: 'Social',
    question: 'Do they step away to take calls or reply to messages?',
  ),

  // ── Phase 2: Behavior verification (one per page) ────────────────
  ChecklistItem(
    id: 'b1',
    phase: 2,
    category: 'Schedule',
    question: 'Are there unexplained gaps in their schedule?',
    detail: 'e.g. unaccounted time blocks, last-minute changes with no reason.',
  ),
  ChecklistItem(
    id: 'b2',
    phase: 2,
    category: 'Schedule',
    question: 'Have they started working late or traveling more often?',
    detail: 'Consider whether this is a new pattern, not a long-standing one.',
  ),
  ChecklistItem(
    id: 'b3',
    phase: 2,
    category: 'Lifestyle',
    question: 'Have you noticed changes in their appearance or grooming habits?',
    detail:
        'e.g. new clothing, more attention to how they look before going out.',
  ),
  ChecklistItem(
    id: 'b4',
    phase: 2,
    category: 'Lifestyle',
    question: 'Have they introduced new interests or references you don\'t recognize?',
    detail: 'New music, places, phrases — things that don\'t trace back to you.',
  ),
  ChecklistItem(
    id: 'b5',
    phase: 2,
    category: 'Digital',
    question: 'Have they changed passwords or enabled extra privacy on devices?',
    detail: 'Especially if this is a recent change with no clear explanation.',
  ),

  // ── Phase 3: Values & cognitive gap (one per page) ───────────────
  ChecklistItem(
    id: 'v1',
    phase: 3,
    category: 'Values',
    question:
        'Do you and your partner share the same boundaries around opposite-sex friendships?',
    detail:
        'Misaligned expectations here are a common source of unspoken conflict.',
  ),
  ChecklistItem(
    id: 'v2',
    phase: 3,
    category: 'Values',
    question:
        'Has there been behavior they normalized that you considered a boundary violation?',
    detail:
        'e.g. "we\'re just friends" dismissing something that felt wrong to you.',
  ),
  ChecklistItem(
    id: 'v3',
    phase: 3,
    category: 'Values',
    question:
        'Have you ever discovered they hid something — and later rationalized it?',
    detail: 'The pattern of hiding + justifying is more significant than the act itself.',
  ),
];
