import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ── Bottom action bar ─────────────────────────────────────────

class ChecklistBottomBar extends StatelessWidget {
  final bool anomalyMode;
  final bool isLast;
  final bool uploading;
  final bool isRecording;
  final VoidCallback onToggleAnomaly;
  final VoidCallback onNext;
  final VoidCallback onFlag;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onAudio;

  const ChecklistBottomBar({
    super.key,
    required this.anomalyMode,
    required this.isLast,
    required this.uploading,
    required this.isRecording,
    required this.onToggleAnomaly,
    required this.onNext,
    required this.onFlag,
    required this.onCamera,
    required this.onGallery,
    required this.onAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // top padding creates the fade-out gradient overhang above the buttons;
      // bottom is 0 — SafeArea already handles the home indicator inset.
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFF000000), Color(0x000A0A0A)],
          stops: [0.0, 1.0],
        ),
      ),
      child: anomalyMode
          // ── Expanded tool panel ────────────────────────────────
          ? AnimatedContainer(
              key: const ValueKey('anomaly'),
              duration: const Duration(milliseconds: 280),
              curve: const Cubic(0.23, 1, 0.32, 1),
              width: double.infinity,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0x66450A0A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x4DEF4444)),
                boxShadow: const [BoxShadow(color: Color(0x26EF4444), blurRadius: 15)],
              ),
              child: ChecklistAnomalyToolPanel(
                onFlag: onFlag,
                onCamera: onCamera,
                onGallery: onGallery,
                onAudio: onAudio,
                onCollapse: onToggleAnomaly,
                uploading: uploading,
                isRecording: isRecording,
              ),
            )
          // ── Collapsed: anomaly button + next button ────────────
          : SizedBox(
              key: const ValueKey('normal'),
              height: 72,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 60,
                    decoration: BoxDecoration(
                      color: const Color(0x1AEF4444),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x80EF4444)),
                      boxShadow: const [BoxShadow(color: Color(0x26EF4444), blurRadius: 15)],
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: onToggleAnomaly,
                      child: const Icon(
                        CupertinoIcons.exclamationmark_circle,
                        color: Color(0xFFEF4444),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: onNext,
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0x1AFFFFFF),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0x33FFFFFF)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLast ? '完成检查' : '未见异常',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(CupertinoIcons.chevron_right,
                                size: 16, color: Color(0x80FFFFFF)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Anomaly tool panel ────────────────────────────────────────

class ChecklistAnomalyToolPanel extends StatelessWidget {
  final VoidCallback onFlag;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onAudio;
  final VoidCallback onCollapse;
  final bool uploading;
  final bool isRecording;

  const ChecklistAnomalyToolPanel({
    super.key,
    required this.onFlag,
    required this.onCamera,
    required this.onGallery,
    required this.onAudio,
    required this.onCollapse,
    required this.uploading,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    final busy = uploading || isRecording;
    return Row(
      children: [
        // Tool buttons
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ToolButton(
                icon: CupertinoIcons.camera,
                label: '拍照',
                onTap: busy ? null : onCamera,
              ),
              _ToolButton(
                icon: CupertinoIcons.photo,
                label: '相册',
                onTap: busy ? null : onGallery,
              ),
              _ToolButton(
                icon: isRecording ? CupertinoIcons.stop_circle : CupertinoIcons.mic,
                label: isRecording ? '停止' : '录音',
                highlight: isRecording,
                onTap: uploading ? null : onAudio,
              ),
              _ToolButton(
                icon: uploading ? CupertinoIcons.clock : CupertinoIcons.flag,
                label: uploading ? '上传中' : '标记',
                onTap: busy ? null : onFlag,
              ),
            ],
          ),
        ),
        // Collapse button — right edge
        Container(
          width: 1,
          height: 40,
          color: const Color(0x1AFFFFFF),
          margin: const EdgeInsets.symmetric(vertical: 20),
        ),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          onPressed: onCollapse,
          child: const Icon(
            CupertinoIcons.chevron_left,
            size: 18,
            color: Color(0x66FFFFFF),
          ),
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool highlight;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1.0,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: highlight
                      ? [const Color(0x33EF4444), const Color(0x1AEF4444)]
                      : [const Color(0x1AFFFFFF), const Color(0x0DFFFFFF)],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: highlight
                      ? const Color(0x80EF4444)
                      : const Color(0x1AFFFFFF),
                ),
              ),
              child: Icon(
                icon,
                size: 18,
                color: highlight
                    ? const Color(0xFFEF4444)
                    : const Color(0xE5FFFFFF),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: highlight
                    ? const Color(0xFFEF4444)
                    : const Color(0x80FFFFFF),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .scale(begin: const Offset(0.8, 0.8), duration: 200.ms)
        .fadeIn(duration: 200.ms);
  }
}
