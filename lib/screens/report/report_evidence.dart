import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/questions.dart';
import '../../providers/investigation_provider.dart' show PendingFile;

// ── Evidence model ────────────────────────────────────────────

class ReportEvidence {
  final String id;
  final ReportEvidenceType type;
  final String title;
  final String timestamp;
  final String? meta;
  /// Local file path for staged (not yet uploaded) evidence — null once uploaded.
  final String? localPath;

  const ReportEvidence({
    required this.id,
    required this.type,
    required this.title,
    required this.timestamp,
    this.meta,
    this.localPath,
  });
}

enum ReportEvidenceType { image, audio, document }

String _fmtDate(DateTime dt) =>
    '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

/// Converts uploaded evidences map + local pending files into a single display list.
/// Pending files appear first (with localPath set); uploaded files follow.
List<ReportEvidence> buildEvidenceList(
  Map<String, List<String>> evidences,
  DateTime completedAt,
  List<PendingFile> pendingFiles,
) {
  final result = <ReportEvidence>[];

  // 1. Local pending files (not yet uploaded)
  for (final p in pendingFiles) {
    final question = kQuestions.where((q) => q.id.toString() == p.itemId).firstOrNull;
    final questionTitle = question?.title ?? '证据 #${p.itemId}';
    final isAudio = p.file.path.contains('.m4a');
    result.add(ReportEvidence(
      id: 'pending_${p.itemId}_${p.file.path.hashCode}',
      type: isAudio ? ReportEvidenceType.audio : ReportEvidenceType.image,
      title: questionTitle,
      timestamp: _fmtDate(DateTime.now()),
      meta: isAudio ? '类型：录音 | 待加密上传' : '类型：图片 | 待加密上传',
      localPath: p.file.path,
    ));
  }

  // 2. Already-uploaded files (fileKey stored in record)
  evidences.forEach((itemId, fileKeys) {
    final question = kQuestions.where((q) => q.id.toString() == itemId).firstOrNull;
    final questionTitle = question?.title ?? '证据 #$itemId';
    for (final fileKey in fileKeys) {
      final isAudio = fileKey.contains('.m4a');
      result.add(ReportEvidence(
        id: fileKey,
        type: isAudio ? ReportEvidenceType.audio : ReportEvidenceType.image,
        title: questionTitle,
        timestamp: _fmtDate(completedAt),
        meta: isAudio ? '类型：录音 | 端对端加密存储' : '类型：图片 | 端对端加密存储',
      ));
    }
  });

  return result;
}

// ── Evidence section ──────────────────────────────────────────

class ReportEvidenceSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<ReportEvidence> onSelect;
  final List<ReportEvidence> evidences;

  const ReportEvidenceSection({
    super.key,
    required this.expanded,
    required this.onToggle,
    required this.onSelect,
    required this.evidences,
  });

  @override
  Widget build(BuildContext context) {
    final shown = expanded ? evidences : evidences.take(2).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  child: const Icon(CupertinoIcons.folder, size: 12, color: Color(0x66FFFFFF)),
                ),
                const SizedBox(width: 10),
                const Text(
                  '关键证据库',
                  style: TextStyle(fontSize: 13, color: Color(0x99FFFFFF), fontWeight: FontWeight.w600, letterSpacing: 3),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x08FFFFFF),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: Text(
                'Items: ${evidences.length}',
                style: const TextStyle(fontSize: 11, color: Color(0x99FFFFFF), fontFamily: 'Courier'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Empty state
        if (evidences.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0x05FFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x0DFFFFFF)),
            ),
            child: const Column(
              children: [
                Icon(CupertinoIcons.folder_badge_plus, size: 28, color: Color(0x33FFFFFF)),
                SizedBox(height: 12),
                Text(
                  '暂无证据文件',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0x4DFFFFFF), height: 1.6),
                ),
              ],
            ),
          ),
        ] else ...[
          // Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
            children: shown
                .map((e) => _EvidenceCard(evidence: e, onTap: () => onSelect(e)))
                .toList(),
          ),
        ],

        // Expand/collapse button
        if (evidences.length > 2) ...[
          const SizedBox(height: 24),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onToggle,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0x05FFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x0DFFFFFF)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    expanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                    size: 12,
                    color: const Color(0x4DFFFFFF),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    expanded ? '收起详细档案' : '展开全部证据 (${evidences.length})',
                    style: const TextStyle(fontSize: 13, color: Color(0x66FFFFFF), fontWeight: FontWeight.w500, letterSpacing: 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  final ReportEvidence evidence;
  final VoidCallback onTap;

  const _EvidenceCard({required this.evidence, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isImage = evidence.type == ReportEvidenceType.image;
    final hasLocal = evidence.localPath != null;

    Widget thumbnail;
    if (isImage && hasLocal) {
      thumbnail = ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: Image.file(
          File(evidence.localPath!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (ctx, err, stack) => const Center(
            child: Icon(CupertinoIcons.photo, size: 32, color: Color(0x1AFFFFFF)),
          ),
        ),
      );
    } else {
      final isAudio = evidence.type == ReportEvidenceType.audio;
      final icon = switch (evidence.type) {
        ReportEvidenceType.image => CupertinoIcons.photo,
        ReportEvidenceType.audio => CupertinoIcons.mic,
        ReportEvidenceType.document => CupertinoIcons.doc_text,
      };
      thumbnail = Container(
        decoration: BoxDecoration(
          color: isAudio ? const Color(0xFF0A1A12) : const Color(0x0AFFFFFF),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Center(
          child: isAudio
              ? Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2B1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x4034D399), width: 1.5),
                  ),
                  child: const Icon(CupertinoIcons.mic, size: 24, color: Color(0xFF34D399)),
                )
              : Icon(icon, size: 32, color: const Color(0x1AFFFFFF)),
        ),
      );
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x05FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x0DFFFFFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: thumbnail),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evidence.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Color(0xCCFFFFFF), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(color: Color(0x33FFFFFF), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          evidence.timestamp,
                          style: const TextStyle(fontSize: 11, color: Color(0x66FFFFFF), fontFamily: 'Courier'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Evidence detail overlay ───────────────────────────────────

class ReportEvidenceOverlay extends StatefulWidget {
  final ReportEvidence evidence;
  final VoidCallback onClose;

  const ReportEvidenceOverlay({super.key, required this.evidence, required this.onClose});

  @override
  State<ReportEvidenceOverlay> createState() => _ReportEvidenceOverlayState();
}

class _ReportEvidenceOverlayState extends State<ReportEvidenceOverlay>
    with SingleTickerProviderStateMixin {
  AudioPlayer? _player;
  bool _isPlaying = false;
  late AnimationController _waveController;

  bool get _isAudio => widget.evidence.type == ReportEvidenceType.audio;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    if (_isAudio) {
      _player = AudioPlayer();
      _player!.playerStateStream.listen((state) {
        if (!mounted) return;
        final playing = state.playing &&
            state.processingState != ProcessingState.completed;
        setState(() => _isPlaying = playing);
        if (playing) {
          _waveController.repeat(reverse: true);
        } else {
          _waveController.stop();
        }
      });
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _player?.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final player = _player;
    if (player == null) return;
    final path = widget.evidence.localPath;
    if (path == null) return;

    if (_isPlaying) {
      await player.pause();
    } else {
      // Re-set source each time so it replays from start if completed
      await player.setFilePath(path);
      await player.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: const Color(0xF2000000),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0x08FFFFFF),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Top area ──────────────────────────────────
                  Stack(
                    children: [
                      _isAudio
                          ? _AudioPreviewArea(
                              isPlaying: _isPlaying,
                              waveController: _waveController,
                              onToggle: _togglePlay,
                              localPath: widget.evidence.localPath,
                            )
                          : AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                                child: widget.evidence.localPath != null
                                    ? Image.file(
                                        File(widget.evidence.localPath!),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (ctx, err, stack) => const Center(
                                          child: Icon(CupertinoIcons.photo, size: 48, color: Color(0x1AFFFFFF)),
                                        ),
                                      )
                                    : Container(
                                        color: const Color(0x14000000),
                                        child: const Center(
                                          child: Icon(CupertinoIcons.photo, size: 48, color: Color(0x1AFFFFFF)),
                                        ),
                                      ),
                              ),
                            ),
                      // Close button
                      Positioned(
                        top: 24,
                        right: 24,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: widget.onClose,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0x66000000),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0x1AFFFFFF)),
                            ),
                            child: const Icon(CupertinoIcons.xmark, size: 20, color: Color(0x66FFFFFF)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Info area ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              widget.evidence.localPath != null ? CupertinoIcons.clock : CupertinoIcons.lock,
                              size: 12,
                              color: widget.evidence.localPath != null ? const Color(0xCCFBBF24) : const Color(0xCC34D399),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.evidence.localPath != null ? '待加密上传' : '已通过区块链存证',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.evidence.localPath != null ? const Color(0xCCFBBF24) : const Color(0xCC34D399),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.evidence.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: Color(0xE5FFFFFF)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.evidence.meta ?? '该原始数据已通过多重加密算法处理，确保在传输过程中的绝对隐私性。',
                          style: const TextStyle(fontSize: 12, color: Color(0x66FFFFFF), fontWeight: FontWeight.w300, height: 1.6),
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 1, child: ColoredBox(color: Color(0x0DFFFFFF))),
                        const SizedBox(height: 12),
                        Text(
                          widget.evidence.timestamp,
                          style: const TextStyle(fontSize: 11, color: Color(0x66FFFFFF), fontFamily: 'Courier', letterSpacing: 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ── Audio preview area ────────────────────────────────────────

class _AudioPreviewArea extends StatelessWidget {
  final bool isPlaying;
  final AnimationController waveController;
  final VoidCallback onToggle;
  final String? localPath;

  const _AudioPreviewArea({
    required this.isPlaying,
    required this.waveController,
    required this.onToggle,
    required this.localPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A1A12),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mic icon badge
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF0D2B1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x4034D399), width: 1.5),
            ),
            child: const Icon(CupertinoIcons.mic, size: 36, color: Color(0xFF34D399)),
          ),
          const SizedBox(height: 28),

          // Waveform bars
          SizedBox(
            height: 48,
            child: AnimatedBuilder(
              animation: waveController,
              builder: (context, _) {
                final t = waveController.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(18, (i) {
                    // Static heights when not playing, animated when playing
                    final double baseH = _kWaveHeights[i % _kWaveHeights.length];
                    final double h = isPlaying
                        ? baseH * (0.4 + 0.6 * _animatedFactor(t, i))
                        : 4.0;
                    return Container(
                      width: 3,
                      height: h,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34D399),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Play button — only shown when localPath exists
          if (localPath != null)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onToggle,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    isPlaying ? '暂停' : '播放加密音频片段',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: const Center(
                child: Text(
                  '已加密 · 无法本地播放',
                  style: TextStyle(fontSize: 14, color: Color(0x66FFFFFF), letterSpacing: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _animatedFactor(double t, int index) {
    // Each bar gets a phase offset for a natural wave effect
    final phase = (index / 18) * 2 * math.pi;
    return (math.sin(t * 2 * math.pi + phase) + 1) / 2;
  }
}

// Bar heights pattern (pixels), looped across 18 bars
const _kWaveHeights = [12.0, 20.0, 32.0, 24.0, 40.0, 28.0, 16.0, 36.0, 44.0,
                       38.0, 22.0, 34.0, 18.0, 42.0, 26.0, 30.0, 14.0, 38.0];
