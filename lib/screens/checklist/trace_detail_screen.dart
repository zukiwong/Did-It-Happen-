import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/investigation_provider.dart';
import '../../services/evidence_service.dart';
import 'detail_visual.dart';

// TraceDetail screen — precise Figma reproduction
// Shows step-by-step instructions for a single checklist question.
// Layout uses pixel-accurate positioning matching Figma frame (393×852).
class TraceDetailScreen extends ConsumerStatefulWidget {
  final int stepIndex;      // 0-based, e.g. 0 = "01"
  final int totalSteps;
  final String itemId;      // checklist item id for evidence keying
  final String category;
  final String title;
  final List<String> steps;
  final List<String> checkpoints;
  final String? tipText;
  final VoidCallback onBack;
  final VoidCallback onNoAnomaly;
  final VoidCallback onFoundAnomaly;

  const TraceDetailScreen({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.itemId,
    required this.category,
    required this.title,
    required this.steps,
    required this.checkpoints,
    this.tipText,
    required this.onBack,
    required this.onNoAnomaly,
    required this.onFoundAnomaly,
  });

  @override
  ConsumerState<TraceDetailScreen> createState() => _TraceDetailScreenState();
}

class _TraceDetailScreenState extends ConsumerState<TraceDetailScreen> {
  bool _evidenceOpen = false;
  bool _uploading = false;
  bool _isRecording = false;

  /// Toggles recording: starts on first tap, stops + uploads on second tap.
  Future<void> _handleAudio() async {
    if (_isRecording) {
      setState(() => _isRecording = false);
      final file = await EvidenceService.stopRecording();
      if (file == null || !mounted) return;
      await _handleUpload(() async => file);
    } else {
      final started = await EvidenceService.startRecording();
      if (mounted && started) setState(() => _isRecording = true);
    }
  }

  Future<void> _handleUpload(Future<dynamic> Function() picker) async {
    final file = await picker();
    if (file == null || !mounted) return;
    final passphrase = ref.read(investigationProvider).passphrase ?? '';
    setState(() => _uploading = true);
    if (passphrase.isNotEmpty) {
      final result = await EvidenceService.uploadEvidence(
        file:       file,
        passphrase: passphrase,
        itemId:     widget.itemId,
      );
      if (mounted && result.success && result.fileKey != null) {
        ref.read(investigationProvider.notifier)
            .addEvidenceKey(widget.itemId, result.fileKey!);
      }
    }
    if (mounted) setState(() => _uploading = false);
    // Mark as flagged regardless of upload success
    ref.read(investigationProvider.notifier)
        .markResult(widget.itemId, 'flagged');
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Figma design is 393×852. We scale positions proportionally.
    final sw = mq.size.width;
    final sh = mq.size.height;
    final scaleX = sw / 393.0;
    final scaleY = sh / 852.0;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF131313),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background subtle texture overlay
          Positioned.fill(
            child: Container(
              color: const Color(0xFF131313),
              child: Opacity(
                opacity: 0.15,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Color(0xFF333333),
                        Color(0xFF131313),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Card background — top-rounded gradient card (Figma: w=343, h=665)
          Positioned(
            left: (sw - 343 * scaleX) / 2,
            top: sh * 0.5 + 93.5 * scaleY - (665 * scaleY) / 2,
            width: 343 * scaleX,
            height: 665 * scaleY,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.89018],
                  colors: [Color(0xFF434343), Color(0xFF131313)],
                ),
                border: Border.all(
                  color: const Color(0x33FFFFFF),
                  width: 1,
                ),
              ),
            ),
          ),

          // ── Header ────────────────────────────────────────────
          Positioned(
            top: mq.padding.top + 12,
            left: 0,
            right: 0,
            child: DetailHeader(
              stepIndex: widget.stepIndex,
              totalSteps: widget.totalSteps,
              scaleX: scaleX,
              onBack: widget.onBack,
            ),
          ),

          // ── Step number + category + title ────────────────────
          Positioned(
            top: 227 * scaleY,
            left: 68 * scaleX,
            child: Text(
              (widget.stepIndex + 1).toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 48 * scaleX,
                fontWeight: FontWeight.w600,
                color: const Color(0x66FF7D7D),
                height: 1.0,
              ),
            ),
          ),

          Positioned(
            top: 264 * scaleY,
            left: 129 * scaleX,
            child: Text(
              widget.category,
              style: TextStyle(
                fontSize: 13 * scaleX,
                color: const Color(0x99FF7D7D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Positioned(
            top: 302 * scaleY,
            left: 68 * scaleX,
            right: 24 * scaleX,
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 22 * scaleX,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),

          // ── Section label "Operation path" ────────────────────
          Positioned(
            top: 348 * scaleY,
            left: 68 * scaleX,
            child: Text(
              'Operation path',
              style: TextStyle(
                fontSize: 13 * scaleX,
                color: const Color(0xFFFF1F1F),
              ),
            ),
          ),

          // ── Step items ────────────────────────────────────────
          ...List.generate(widget.steps.length, (i) {
            final top = (374 + i * 29) * scaleY;
            return Positioned(
              top: top,
              left: 68 * scaleX,
              right: 24 * scaleX,
              child: DetailStepRow(
                index: i + 1,
                text: widget.steps[i],
                scaleX: scaleX,
              ),
            );
          }),

          // ── Section label "Key confirmation" ──────────────────
          Positioned(
            top: 444 * scaleY,
            left: 68 * scaleX,
            child: Text(
              'Key confirmation',
              style: TextStyle(
                fontSize: 13 * scaleX,
                color: const Color(0xFFFF1F1F),
              ),
            ),
          ),

          // ── Checkpoint bullets ────────────────────────────────
          ...List.generate(widget.checkpoints.length, (i) {
            final top = (470 + i * 28) * scaleY;
            return Positioned(
              top: top,
              left: 68 * scaleX,
              right: 24 * scaleX,
              child: DetailBulletRow(
                text: widget.checkpoints[i],
                scaleX: scaleX,
              ),
            );
          }),

          // ── Divider line ──────────────────────────────────────
          Positioned(
            top: 575 * scaleY,
            left: (sw - 279 * scaleX) / 2 + 5 * scaleX,
            width: 279 * scaleX,
            height: 1,
            child: const ColoredBox(color: Color(0x80FFFFFF)),
          ),

          // ── Tip text ──────────────────────────────────────────
          if (widget.tipText != null)
            Positioned(
              top: 591 * scaleY,
              left: 68 * scaleX,
              right: 24 * scaleX,
              child: Text(
                widget.tipText!,
                style: TextStyle(
                  fontSize: 14 * scaleX,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ),

          // ── Action buttons ────────────────────────────────────
          Positioned(
            top: 661 * scaleY,
            left: 62 * scaleX,
            width: 279 * scaleX,
            child: DetailAnomalyButton(
              scaleX: scaleX,
              scaleY: scaleY,
              onTap: () => setState(() => _evidenceOpen = true),
            ),
          ),

          Positioned(
            top: 738 * scaleY,
            left: 62 * scaleX,
            width: 279 * scaleX,
            child: DetailCleanButton(
              scaleX: scaleX,
              scaleY: scaleY,
              onTap: widget.onNoAnomaly,
            ),
          ),

          // ── Evidence bottom sheet ─────────────────────────────
          if (_evidenceOpen)
            DetailEvidenceSheet(
              onClose: () {
                setState(() => _evidenceOpen = false);
                widget.onFoundAnomaly();
              },
              onDismiss: () => setState(() => _evidenceOpen = false),
              onCamera:    () => _handleUpload(EvidenceService.pickFromCamera),
              onGallery:   () => _handleUpload(EvidenceService.pickFromGallery),
              onAudio:     _handleAudio,
              uploading:   _uploading,
              isRecording: _isRecording,
              scaleX: scaleX,
              scaleY: scaleY,
              sh: sh,
              sw: sw,
            ).animate().fadeIn(duration: 200.ms),
        ],
      ),
    );
  }
}
