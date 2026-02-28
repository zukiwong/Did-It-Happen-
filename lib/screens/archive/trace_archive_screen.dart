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
  final Map<int, ArchiveQuestionResponse> _responses = {
    1: ArchiveQuestionResponse(
      questionId: 1,
      status: ArchiveRecordStatus.anomaly,
      evidences: [
        ArchiveEvidence(
          id: 'ev1',
          timestamp: '2026.03.12 23:15',
          type: ArchiveEvidenceType.image,
        ),
      ],
    ),
    3: ArchiveQuestionResponse(
      questionId: 3,
      status: ArchiveRecordStatus.anomaly,
      evidences: [
        ArchiveEvidence(
          id: 'ev2',
          timestamp: '2026.03.08 19:22',
          type: ArchiveEvidenceType.image,
        ),
      ],
    ),
  };

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
      final existing = _responses[questionId];
      if (existing != null) {
        _responses[questionId] = ArchiveQuestionResponse(
          questionId: questionId,
          status: existing.status == ArchiveRecordStatus.clean
              ? ArchiveRecordStatus.anomaly
              : ArchiveRecordStatus.clean,
          evidences: existing.evidences,
        );
      } else {
        _responses[questionId] = ArchiveQuestionResponse(
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
      timestamp: '2026.02.25 15:45',
      type: ArchiveEvidenceType.image,
    );
    setState(() {
      final existing = _responses[questionId];
      if (existing != null) {
        _responses[questionId] = ArchiveQuestionResponse(
          questionId: questionId,
          status: ArchiveRecordStatus.anomaly,
          evidences: [...existing.evidences, newEv],
        );
      } else {
        _responses[questionId] = ArchiveQuestionResponse(
          questionId: questionId,
          status: ArchiveRecordStatus.anomaly,
          evidences: [newEv],
        );
      }
    });
  }

  void _deleteEvidence(int questionId, String evidenceId) {
    setState(() {
      final existing = _responses[questionId];
      if (existing != null) {
        _responses[questionId] = ArchiveQuestionResponse(
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

                      // Question records
                      ..._filtered.map((q) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ArchiveRecordItem(
                              question: q,
                              response: _responses[q.id],
                              onToggleStatus: () => _toggleStatus(q.id),
                              onAddEvidence: () => _addEvidence(q.id),
                              onDeleteEvidence: (evId) =>
                                  _deleteEvidence(q.id, evId),
                            ),
                          )),

                      // Observation log
                      ArchiveObservationLog(
                        record: ref.watch(investigationProvider).record,
                      ),
                    ]),
                  ),
                ),
              ),
            ],
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
