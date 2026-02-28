import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/evidence_service.dart' show EvidenceService;
import '../../data/questions.dart';
import '../../providers/investigation_provider.dart';
import '../../services/investigation_storage_service.dart';
import 'report_visual.dart';
import 'report_evidence.dart' show ReportEvidenceSection, ReportEvidenceOverlay, ReportEvidence, buildEvidenceList;
import 'report_timeline.dart';
import 'report_key_section.dart';

// TraceReport — 痕迹观察报告
// Sections: cinematic visual, findings grid, evidence collector,
// timeline, secret key / lock section.
class TraceReportScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const TraceReportScreen({super.key, required this.onBack});

  @override
  ConsumerState<TraceReportScreen> createState() => _TraceReportScreenState();
}

class _TraceReportScreenState extends ConsumerState<TraceReportScreen> {
  ReportUnlockState _unlockState = ReportUnlockState.input;
  final _keyController = TextEditingController();
  bool _evidenceExpanded = false;
  ReportEvidence? _selectedEvidence;
  String? _saveError;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmKey() async {
    final passphrase = _keyController.text.trim();
    if (passphrase.isEmpty) return;

    ref.read(investigationProvider.notifier).setPassphrase(passphrase);

    // Batch-upload any files staged during checklist (passphrase was not set then)
    final pending = ref.read(investigationProvider).pendingFiles;
    for (final p in pending) {
      final result = await EvidenceService.uploadEvidence(
        file:       p.file,
        passphrase: passphrase,
        itemId:     p.itemId,
      );
      if (result.success && result.fileKey != null) {
        ref.read(investigationProvider.notifier).addEvidenceKey(p.itemId, result.fileKey!);
      }
    }
    // Clear the staging queue
    if (pending.isNotEmpty) {
      ref.read(investigationProvider.notifier).clearPendingFiles();
    }

    final status = await ref.read(investigationProvider.notifier).save();
    if (!mounted) return;

    if (status == SaveStatus.success) {
      setState(() {
        _unlockState = ReportUnlockState.unlocked;
        _saveError = null;
      });
    } else {
      setState(() {
        _saveError = status == SaveStatus.passphraseConflict
            ? '该密钥已被其他档案使用，请换一个。'
            : '保存失败，请检查网络连接。';
      });
    }
  }

  /// Returns titles of flagged questions belonging to the given categories.
  List<String> _flaggedItemsFor(Map<String, String> results, List<String> categories) {
    return kQuestions
        .where((q) => categories.contains(q.category) && results[q.id.toString()] == 'flagged')
        .map((q) => q.title)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(investigationProvider).record?.results ?? {};

    // 核心行为模式 — 人的行为变化 + 社交互动动态
    final behaviorItems = _flaggedItemsFor(results, ['行为变化与异常', '社交与聊天痕迹', '短视频与社交平台痕迹']);
    // 关键线索 — 有据可查的物证和轨迹
    final clueItems     = _flaggedItemsFor(results, ['消费与地址痕迹', '行程与位置痕迹']);
    // 关联设备 — 手机/App 上留下的数字痕迹
    final deviceItems   = _flaggedItemsFor(results, ['应用与设备痕迹']);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF050505),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ReportBackground(),

          CustomScrollView(
            slivers: [
              SliverSafeArea(
                sliver: SliverPadding(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ReportHeader(
                        onBack: widget.onBack,
                        isSaved: _unlockState == ReportUnlockState.input,
                      ),
                      const SizedBox(height: 24),

                      const ReportCinematicVisual(),
                      const SizedBox(height: 16),

                      ReportStatsRow(
                        flaggedCount: results.values.where((v) => v == 'flagged').length,
                        totalCount: kQuestions.length,
                      ),
                      const SizedBox(height: 56),

                      ReportInfoCard(
                        title: '核心行为模式',
                        icon: CupertinoIcons.waveform_path,
                        items: behaviorItems,
                        emptyHint: '未发现行为异常',
                        delay: 200,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ReportInfoCard(
                              title: '关键线索',
                              icon: CupertinoIcons.layers_alt,
                              items: clueItems,
                              emptyHint: '未发现异常线索',
                              delay: 400,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ReportInfoCard(
                              title: '关联设备',
                              icon: CupertinoIcons.device_laptop,
                              items: deviceItems,
                              emptyHint: '未发现设备异常',
                              delay: 500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 56),

                      ReportEvidenceSection(
                        expanded: _evidenceExpanded,
                        onToggle: () => setState(() => _evidenceExpanded = !_evidenceExpanded),
                        onSelect: (e) => setState(() => _selectedEvidence = e),
                        evidences: buildEvidenceList(
                          ref.watch(investigationProvider).record?.evidences ?? {},
                          ref.watch(investigationProvider).record?.completedAt ?? DateTime.now(),
                          ref.watch(investigationProvider).pendingFiles,
                        ),
                      ),
                      const SizedBox(height: 56),

                      ReportTimelineSection(
                        record: ref.watch(investigationProvider).record,
                      ),
                      const SizedBox(height: 64),

                      ReportKeySection(
                        unlockState: _unlockState,
                        controller: _keyController,
                        onConfirm: _handleConfirmKey,
                        errorText: _saveError,
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          ),

          if (_selectedEvidence != null)
            ReportEvidenceOverlay(
              evidence: _selectedEvidence!,
              onClose: () => setState(() => _selectedEvidence = null),
            ),
        ],
      ),
    );
  }
}
