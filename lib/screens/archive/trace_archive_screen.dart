import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/questions.dart';
import '../../providers/investigation_provider.dart';
import 'archive_visual.dart';

// TraceArchive — historical observation records with search, filter,
// expand/collapse per question, evidence management, and observation log.
class TraceArchiveScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const TraceArchiveScreen({super.key, required this.onBack});

  @override
  ConsumerState<TraceArchiveScreen> createState() => _TraceArchiveScreenState();
}

class _TraceArchiveScreenState extends ConsumerState<TraceArchiveScreen> {
  // Local overrides: user can toggle/add/delete within this session.
  // Keyed by questionId; null means "use record data as-is".
  final Map<int, ArchiveQuestionResponse> _overrides = {};

  // Evidence selected for preview overlay.
  ArchiveEvidence? _selectedEvidence;

  static String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  // Derive responses from the live record, merged with local overrides.
  // Use ref.read so this can be safely called outside build() (e.g. in setState).
  Map<int, ArchiveQuestionResponse> _buildResponses() {
    final record = ref.read(investigationProvider).record;
    final map = <int, ArchiveQuestionResponse>{};
    if (record != null) {
      for (final entry in record.results.entries) {
        final qId = int.tryParse(entry.key);
        if (qId == null) continue;
        if (entry.value == 'flagged') {
          final keys = record.evidences[entry.key] ?? [];
          final evList = keys.asMap().entries.map((e) {
            final isAudio = e.value.contains('.m4a');
            return ArchiveEvidence(
              id:        e.value,
              timestamp: _formatDate(record.completedAt),
              type:      isAudio ? ArchiveEvidenceType.audio : ArchiveEvidenceType.image,
            );
          }).toList();
          map[qId] = ArchiveQuestionResponse(
            questionId: qId,
            status:     ArchiveRecordStatus.anomaly,
            evidences:  evList,
          );
        }
      }
    }
    // Apply local overrides on top
    map.addAll(_overrides);
    return map;
  }

  String _selectedCategory = '全部';
  String _searchQuery = '';

  List<String> get _categories {
    final cats = kQuestions.map((q) => q.category).toSet().toList();
    return ['全部', ...cats];
  }

  List<QuestionItem> get _filtered {
    return kQuestions.where((q) {
      final matchCat =
          _selectedCategory == '全部' || q.category == _selectedCategory;
      final matchSearch =
          q.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  void _toggleStatus(int questionId) {
    setState(() {
      final existing = _buildResponses()[questionId];
      if (existing != null) {
        _overrides[questionId] = ArchiveQuestionResponse(
          questionId: questionId,
          status: existing.status == ArchiveRecordStatus.clean
              ? ArchiveRecordStatus.anomaly
              : ArchiveRecordStatus.clean,
          evidences: existing.evidences,
        );
      } else {
        _overrides[questionId] = ArchiveQuestionResponse(
          questionId: questionId,
          status: ArchiveRecordStatus.anomaly,
          evidences: [],
        );
      }
    });
  }

  void _addEvidence(int questionId) {
    final newEv = ArchiveEvidence(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: _formatDate(DateTime.now()),
      type: ArchiveEvidenceType.image,
    );
    setState(() {
      final existing = _buildResponses()[questionId];
      if (existing != null) {
        _overrides[questionId] = ArchiveQuestionResponse(
          questionId: questionId,
          status: ArchiveRecordStatus.anomaly,
          evidences: [...existing.evidences, newEv],
        );
      } else {
        _overrides[questionId] = ArchiveQuestionResponse(
          questionId: questionId,
          status: ArchiveRecordStatus.anomaly,
          evidences: [newEv],
        );
      }
    });
  }

  void _deleteEvidence(int questionId, String evidenceId) {
    setState(() {
      final existing = _buildResponses()[questionId];
      if (existing != null) {
        _overrides[questionId] = ArchiveQuestionResponse(
          questionId: questionId,
          status: existing.status,
          evidences: existing.evidences
              .where((e) => e.id != evidenceId)
              .toList(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider so any record change triggers a rebuild.
    ref.watch(investigationProvider);
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF050505),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          const ArchiveBackground(),

          // Content
          CustomScrollView(
            slivers: [
              SliverSafeArea(
                sliver: SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Header
                      ArchiveHeader(onBack: widget.onBack),
                      const SizedBox(height: 40),

                      // Filter bar
                      ArchiveFilterBar(
                        searchQuery: _searchQuery,
                        selectedCategory: _selectedCategory,
                        categories: _categories,
                        onSearch: (v) => setState(() => _searchQuery = v),
                        onCategorySelect: (c) =>
                            setState(() => _selectedCategory = c),
                      ),
                      const SizedBox(height: 32),

                      // Question records — derived from live record each build
                      ...() {
                        final responses = _buildResponses();
                        return _filtered.map((q) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ArchiveRecordItem(
                            question:        q,
                            response:        responses[q.id],
                            passphrase:      ref.read(investigationProvider).passphrase ?? '',
                            onToggleStatus:  () => _toggleStatus(q.id),
                            onAddEvidence:   () => _addEvidence(q.id),
                            onDeleteEvidence: (evId) => _deleteEvidence(q.id, evId),
                            onTapEvidence:   (ev) => setState(() => _selectedEvidence = ev),
                          ),
                        ));
                      }(),

                      // Observation log
                      ArchiveObservationLog(
                        record: ref.read(investigationProvider).record,
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          ),

          // Evidence preview overlay
          if (_selectedEvidence != null)
            Positioned.fill(
              child: ArchiveEvidenceOverlay(
                evidence:   _selectedEvidence!,
                passphrase: ref.read(investigationProvider).passphrase ?? '',
                onClose:    () => setState(() => _selectedEvidence = null),
              ),
            ),

          // Floating save button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFF000000), Color(0x00000000)],
                ),
              ),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  await ref.read(investigationProvider.notifier).save();
                  widget.onBack();
                },
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1AFFFFFF),
                        blurRadius: 40,
                        offset: Offset(0, 20),
                      )
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '更新观察结果',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF000000),
                          letterSpacing: 6,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(CupertinoIcons.arrow_right,
                          size: 16, color: Color(0xFF000000)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
