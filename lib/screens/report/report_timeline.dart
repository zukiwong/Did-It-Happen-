import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/investigation_storage_service.dart';

// ── Shared timeline entry model ───────────────────────────────

class TimelineEntry {
  final String date;   // e.g. '2026.02.25 14:20'
  final String title;
  final bool isLatest; // green dot highlight

  const TimelineEntry({
    required this.date,
    required this.title,
    this.isLatest = false,
  });
}

String _fmt(DateTime dt) =>
    '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

/// Builds dynamic timeline entries from a real InvestigationRecord.
/// Falls back to a single placeholder entry when record is null.
List<TimelineEntry> buildTimelineEntries(InvestigationRecord? record) {
  if (record == null) {
    return [
      TimelineEntry(
        date: _fmt(DateTime.now()),
        title: '档案建立中',
        isLatest: true,
      ),
    ];
  }

  final entries = <TimelineEntry>[];
  final t = record.completedAt;

  // Entry 1: session started
  entries.add(TimelineEntry(
    date: _fmt(t),
    title: '建立观察档案，开始逐项记录',
  ));

  // Entry 2: flagged count summary (if any anomalies found)
  final flagged = record.results.values.where((v) => v == 'flagged').length;
  final total   = record.results.length;
  if (total > 0) {
    entries.add(TimelineEntry(
      date: _fmt(t.add(const Duration(minutes: 1))),
      title: flagged > 0
          ? '完成 $total 项观察，发现 $flagged 项异常信号'
          : '完成 $total 项观察，未发现明显异常',
    ));
  }

  // Entry 3: evidence uploaded (if any)
  final evidenceCount = record.evidences.values.fold<int>(0, (s, v) => s + v.length);
  if (evidenceCount > 0) {
    entries.add(TimelineEntry(
      date: _fmt(t.add(const Duration(minutes: 2))),
      title: '已上传 $evidenceCount 份加密证据文件',
      isLatest: true,
    ));
  } else {
    // Mark last entry as latest when no evidence
    if (entries.isNotEmpty) {
      final last = entries.removeLast();
      entries.add(TimelineEntry(date: last.date, title: last.title, isLatest: true));
    }
  }

  return entries;
}

// ── Report timeline section (compact style for report page) ───

class ReportTimelineSection extends StatelessWidget {
  final InvestigationRecord? record;

  const ReportTimelineSection({super.key, this.record});

  @override
  Widget build(BuildContext context) {
    final items = buildTimelineEntries(record);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0x08FFFFFF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: const Icon(CupertinoIcons.clock, size: 12, color: Color(0x66FFFFFF)),
            ),
            const SizedBox(width: 10),
            const Text(
              '观察日志记录',
              style: TextStyle(fontSize: 13, color: Color(0x99FFFFFF), fontWeight: FontWeight.w600, letterSpacing: 3),
            ),
          ],
        ),
        const SizedBox(height: 32),
        ...items.asMap().entries.map((e) {
          final i    = e.key;
          final item = e.value;
          return _TimelineItem(
            date: item.date,
            title: item.title,
            isNew: item.isLatest,
            isLast: i == items.length - 1,
            delay: 600 + i * 100,
          );
        }),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String date;
  final String title;
  final bool isNew;
  final bool isLast;
  final int delay;

  const _TimelineItem({
    required this.date,
    required this.title,
    required this.isNew,
    required this.isLast,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isNew ? const Color(0xFF34D399) : const Color(0xFF050505),
                    border: Border.all(
                      color: isNew ? const Color(0xFF34D399) : const Color(0x33FFFFFF),
                      width: 2,
                    ),
                    boxShadow: isNew
                        ? const [BoxShadow(color: Color(0x6610B981), blurRadius: 12)]
                        : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 1, color: const Color(0x0DFFFFFF)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(fontSize: 11, color: Color(0x66FFFFFF), fontFamily: 'Courier', letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isNew ? FontWeight.w500 : FontWeight.w300,
                      color: isNew ? const Color(0xE534D399) : const Color(0x99FFFFFF),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 500.ms)
        .slideX(begin: -0.2, end: 0);
  }
}
