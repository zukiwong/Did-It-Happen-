import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/questions.dart';
import '../../providers/investigation_provider.dart';
import '../../services/evidence_service.dart';
import 'checklist_visual.dart';
import 'checklist_bottom_bar.dart';

// TraceChecklist — TA出轨路径的逐题卡片清单
// Each card slides in/out horizontally. Bottom bar has:
//   - Red anomaly button (expands to show 拍照/相册/录音/标记 tools)
//   - White "未见异常" next button
class TraceChecklistScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const TraceChecklistScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<TraceChecklistScreen> createState() =>
      _TraceChecklistScreenState();
}

class _TraceChecklistScreenState
    extends ConsumerState<TraceChecklistScreen> {
  int _currentIndex = 0;
  bool _anomalyMode = false;
  int _direction = 0; // 1 = forward, -1 = backward
  bool _uploading = false;
  bool _isRecording = false;

  QuestionItem get _current => kQuestions[_currentIndex];
  bool get _isLast => _currentIndex == kQuestions.length - 1;
  String get _itemId => _current.id.toString();

  void _handleNext() {
    ref.read(investigationProvider.notifier).markResult(_itemId, 'normal');
    if (_isLast) {
      widget.onNext();
    } else {
      setState(() {
        _direction = 1;
        _anomalyMode = false;
        _currentIndex++;
      });
    }
  }

  void _handleFlag() {
    ref.read(investigationProvider.notifier).markResult(_itemId, 'flagged');
    if (_isLast) {
      widget.onNext();
    } else {
      setState(() {
        _direction = 1;
        _anomalyMode = false;
        _currentIndex++;
      });
    }
  }

  void _handlePrev() {
    if (_currentIndex > 0) {
      setState(() {
        _direction = -1;
        _anomalyMode = false;
        _currentIndex--;
      });
    } else {
      widget.onBack();
    }
  }

  Future<void> _pickCamera() async {
    final file = await EvidenceService.pickFromCamera();
    if (file == null || !mounted) return;
    await _uploadFile(file);
  }

  Future<void> _pickGallery() async {
    final file = await EvidenceService.pickFromGallery();
    if (file == null || !mounted) return;
    await _uploadFile(file);
  }

  /// Toggles recording: starts on first tap, stops + uploads on second tap.
  Future<void> _handleAudio() async {
    if (_isRecording) {
      // Stop and upload
      setState(() => _isRecording = false);
      final file = await EvidenceService.stopRecording();
      if (file == null || !mounted) return;
      await _uploadFile(file);
    } else {
      // Start recording
      final started = await EvidenceService.startRecording();
      if (!mounted) return;
      if (started) {
        setState(() => _isRecording = true);
      }
    }
  }

  Future<void> _uploadFile(File file) async {
    final passphrase = ref.read(investigationProvider).passphrase ?? '';
    if (passphrase.isEmpty) {
      // No passphrase yet — stage locally, upload when key is set on report page
      ref.read(investigationProvider.notifier).stagePendingFile(_itemId, file);
      ref.read(investigationProvider.notifier).markResult(_itemId, 'flagged');
      return;
    }
    setState(() => _uploading = true);
    final result = await EvidenceService.uploadEvidence(
      file:       file,
      passphrase: passphrase,
      itemId:     _itemId,
    );
    if (!mounted) return;
    if (result.success && result.fileKey != null) {
      ref.read(investigationProvider.notifier).addEvidenceKey(_itemId, result.fileKey!);
      ref.read(investigationProvider.notifier).markResult(_itemId, 'flagged');
    }
    setState(() => _uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ChecklistAmbientBackground(),

          SafeArea(
            child: Column(
              children: [
                ChecklistTopBar(
                  currentIndex: _currentIndex,
                  total: kQuestions.length,
                  onBack: _handlePrev,
                ),

                Expanded(
                  child: ChecklistAnimatedCard(
                    key: ValueKey(_currentIndex),
                    direction: _direction,
                    child: ChecklistQuestionCard(item: _current),
                  ),
                ),

                ChecklistBottomBar(
                  anomalyMode: _anomalyMode,
                  isLast: _isLast,
                  uploading: _uploading,
                  isRecording: _isRecording,
                  onToggleAnomaly: () =>
                      setState(() => _anomalyMode = !_anomalyMode),
                  onNext: _handleNext,
                  onFlag: _handleFlag,
                  onCamera: _pickCamera,
                  onGallery: _pickGallery,
                  onAudio: _handleAudio,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
