import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/questions.dart';
import '../../services/investigation_storage_service.dart';
import '../report/report_timeline.dart' show buildTimelineEntries;

// ── Data models ───────────────────────────────────────────────

enum ArchiveRecordStatus { clean, anomaly }

enum ArchiveEvidenceType { image, audio }

class ArchiveEvidence {
  final String id;
  final String timestamp;
  final ArchiveEvidenceType type;

  const ArchiveEvidence({
    required this.id,
    required this.timestamp,
    required this.type,
  });
}

class ArchiveQuestionResponse {
  final int questionId;
  final ArchiveRecordStatus status;
  final List<ArchiveEvidence> evidences;

  const ArchiveQuestionResponse({
    required this.questionId,
    required this.status,
    required this.evidences,
  });
}

// ── Background ────────────────────────────────────────────────

class ArchiveBackground extends StatelessWidget {
  const ArchiveBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF050505)),
        Positioned(
          top: -size.height * 0.25,
          right: -size.width * 0.25,
          width: size.width * 1.5,
          height: size.width * 1.5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.8, 0.2),
                colors: [Color(0x1A172554), Color(0x00000000)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────

class ArchiveHeader extends StatelessWidget {
  final VoidCallback onBack;

  const ArchiveHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onBack,
          child: const Icon(CupertinoIcons.chevron_left,
              size: 24, color: Color(0x99FFFFFF)),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Icon(CupertinoIcons.time, size: 20, color: Color(0x66FFFFFF)),
            SizedBox(width: 12),
            Text(
              '历史观察档案',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: Color(0xE5FFFFFF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '已验证访问',
          style: TextStyle(
            fontSize: 10,
            color: Color(0x33FFFFFF),
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────

class ArchiveFilterBar extends StatelessWidget {
  final String searchQuery;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onCategorySelect;

  const ArchiveFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedCategory,
    required this.categories,
    required this.onSearch,
    required this.onCategorySelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            CupertinoTextField(
              placeholder: '检索历史线索...',
              onChanged: onSearch,
              style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
              placeholderStyle:
                  const TextStyle(color: Color(0x1AFFFFFF), fontSize: 14),
              padding: const EdgeInsets.fromLTRB(48, 14, 16, 14),
              decoration: BoxDecoration(
                color: const Color(0x08FFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(CupertinoIcons.search,
                  size: 16, color: Color(0x1AFFFFFF)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Category chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final selected = cat == selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => onCategorySelect(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFFFFFFF)
                          : const Color(0x08FFFFFF),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFFFFFFF)
                            : const Color(0x0DFFFFFF),
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: selected
                            ? const Color(0xFF000000)
                            : const Color(0x66FFFFFF),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Record item (expandable) ──────────────────────────────────

class ArchiveRecordItem extends StatefulWidget {
  final QuestionItem question;
  final ArchiveQuestionResponse? response;
  final VoidCallback onToggleStatus;
  final VoidCallback onAddEvidence;
  final ValueChanged<String> onDeleteEvidence;

  const ArchiveRecordItem({
    super.key,
    required this.question,
    required this.response,
    required this.onToggleStatus,
    required this.onAddEvidence,
    required this.onDeleteEvidence,
  });

  @override
  State<ArchiveRecordItem> createState() => _ArchiveRecordItemState();
}

class _ArchiveRecordItemState extends State<ArchiveRecordItem> {
  bool _expanded = false;

  bool get _isAnomaly =>
      widget.response?.status == ArchiveRecordStatus.anomaly;
  bool get _hasEvidence =>
      widget.response != null && widget.response!.evidences.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _expanded
            ? const Color(0x0AFFFFFF)
            : const Color(0x05FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _expanded
              ? const Color(0x1AFFFFFF)
              : const Color(0x0DFFFFFF),
        ),
        boxShadow: _expanded
            ? const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 32,
                  offset: Offset(0, 8),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collapsed header — tap to expand
          CupertinoButton(
            padding: const EdgeInsets.all(20),
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '#${widget.question.id.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 8,
                              color: Color(0x33FFFFFF),
                              fontFamily: 'Courier',
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.question.category,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 8,
                                color: Color(0x4DFFFFFF),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.question.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: _expanded
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xB3FFFFFF),
                          height: 1.5,
                        ),
                      ),
                      if (!_expanded && (_hasEvidence || _isAnomaly)) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (_isAnomaly)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              )
                                  .animate(onPlay: (c) => c.repeat(reverse: true))
                                  .custom(
                                    duration: 1000.ms,
                                    builder: (_, val, child) =>
                                        Opacity(opacity: 0.5 + val * 0.5, child: child),
                                  ),
                            if (_hasEvidence) ...[
                              const SizedBox(width: 8),
                              Text(
                                '[${widget.response!.evidences.length} 证据]',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0x33FFFFFF),
                                  fontFamily: 'Courier',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    if (_isAnomaly && !_expanded)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(
                          CupertinoIcons.exclamationmark_circle,
                          size: 16,
                          color: Color(0x80EF4444),
                        ),
                      ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0x0DFFFFFF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0x1AFFFFFF)),
                        ),
                        child: const Icon(
                          CupertinoIcons.chevron_down,
                          size: 12,
                          color: Color(0x33FFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expanded content
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: ArchiveExpandedContent(
              question: widget.question,
              response: widget.response,
              isAnomaly: _isAnomaly,
              hasEvidence: _hasEvidence,
              onToggleStatus: widget.onToggleStatus,
              onAddEvidence: widget.onAddEvidence,
              onDeleteEvidence: widget.onDeleteEvidence,
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

// ── Expanded content ──────────────────────────────────────────

class ArchiveExpandedContent extends StatelessWidget {
  final QuestionItem question;
  final ArchiveQuestionResponse? response;
  final bool isAnomaly;
  final bool hasEvidence;
  final VoidCallback onToggleStatus;
  final VoidCallback onAddEvidence;
  final ValueChanged<String> onDeleteEvidence;

  const ArchiveExpandedContent({
    super.key,
    required this.question,
    required this.response,
    required this.isAnomaly,
    required this.hasEvidence,
    required this.onToggleStatus,
    required this.onAddEvidence,
    required this.onDeleteEvidence,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider
          Container(height: 1, color: const Color(0x0DFFFFFF)),
          const SizedBox(height: 20),

          // Subtitle
          if (question.subtitle != null) ...[
            Text(
              question.subtitle!,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0x99FF7D7D),
                fontWeight: FontWeight.w500,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Points
          ...question.points.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x05FFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x0DFFFFFF)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0x1AFFFFFF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          p,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0x80FFFFFF),
                            fontWeight: FontWeight.w300,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),

          if (question.tip != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(CupertinoIcons.exclamationmark_circle,
                    size: 12, color: Color(0x33FFFFFF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question.tip!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0x4DFFFFFF),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),

          // Status toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '记录定性',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0x33FFFFFF),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onToggleStatus,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isAnomaly
                        ? const Color(0x1AEF4444)
                        : const Color(0x08FFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAnomaly
                          ? const Color(0x4DEF4444)
                          : const Color(0x1AFFFFFF),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAnomaly
                            ? CupertinoIcons.flag
                            : CupertinoIcons.checkmark_circle,
                        size: 12,
                        color: isAnomaly
                            ? const Color(0xFFF87171)
                            : const Color(0x4DFFFFFF),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAnomaly ? '标记为异常' : '标记为正常',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: isAnomaly
                              ? const Color(0xFFF87171)
                              : const Color(0x4DFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Evidence section
          if (isAnomaly || hasEvidence) ...[
            const SizedBox(height: 20),
            const Text(
              '线索存证',
              style: TextStyle(
                fontSize: 9,
                color: Color(0x33FFFFFF),
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (response != null)
                  ...response!.evidences.map((ev) => ArchiveEvidenceThumbnail(
                        evidence: ev,
                        onDelete: () => onDeleteEvidence(ev.id),
                      )),
                // Add button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onAddEvidence,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0x1AFFFFFF),
                        style: BorderStyle.solid,
                      ),
                      color: const Color(0x03FFFFFF),
                    ),
                    child: const Icon(
                      CupertinoIcons.add,
                      size: 16,
                      color: Color(0x1AFFFFFF),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Evidence thumbnail ────────────────────────────────────────

class ArchiveEvidenceThumbnail extends StatelessWidget {
  final ArchiveEvidence evidence;
  final VoidCallback onDelete;

  const ArchiveEvidenceThumbnail({
    super.key,
    required this.evidence,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0x0AFFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x1AFFFFFF)),
          ),
          child: Icon(
            evidence.type == ArchiveEvidenceType.audio
                ? CupertinoIcons.mic
                : CupertinoIcons.photo,
            size: 24,
            color: const Color(0x33FFFFFF),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onDelete,
            minimumSize: Size.zero,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0x99000000),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: const Icon(
                CupertinoIcons.trash,
                size: 10,
                color: Color(0x66FFFFFF),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Observation log ───────────────────────────────────────────

class ArchiveObservationLog extends StatelessWidget {
  final InvestigationRecord? record;

  const ArchiveObservationLog({super.key, this.record});

  @override
  Widget build(BuildContext context) {
    final logs = buildTimelineEntries(record);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 64),
        Container(height: 1, color: const Color(0x0DFFFFFF)),
        const SizedBox(height: 48),
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0x08FFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: const Icon(CupertinoIcons.clock, size: 16, color: Color(0x66FFFFFF)),
            ),
            const SizedBox(width: 12),
            const Text(
              '观察日志记录',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: Color(0xCCFFFFFF)),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Stack(
            children: [
              Positioned(
                left: 7, top: 8, bottom: 8, width: 1,
                child: Container(color: const Color(0x0DFFFFFF)),
              ),
              Column(
                children: logs.asMap().entries.map((e) {
                  final i   = e.key;
                  final log = e.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: log.isLatest
                                ? const Color(0xFF34D399)
                                : const Color(0x1AFFFFFF),
                            boxShadow: log.isLatest
                                ? const [BoxShadow(color: Color(0x8034D399), blurRadius: 12)]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.date,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0x33FFFFFF),
                                  fontFamily: 'Courier',
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                log.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: log.isLatest ? FontWeight.w500 : FontWeight.w300,
                                  color: log.isLatest
                                      ? const Color(0xE534D399)
                                      : const Color(0x80FFFFFF),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: i * 100), duration: 500.ms)
                      .slideX(begin: -0.1, end: 0);
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
