import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ── Header ────────────────────────────────────────────────────

class DetailHeader extends StatelessWidget {
  final int stepIndex;
  final int totalSteps;
  final double scaleX;
  final VoidCallback onBack;

  const DetailHeader({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.scaleX,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scaleX),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: onBack,
            child: const Icon(
              CupertinoIcons.chevron_left,
              color: Color(0xFFFFFFFF),
              size: 24,
            ),
          ),
          const Spacer(),
          // Title group: "Trace Record" + "1/12"
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Trace Record',
                    style: TextStyle(
                      fontSize: 20 * scaleX,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                  SizedBox(width: 12 * scaleX),
                  Text(
                    '${stepIndex + 1}/$totalSteps',
                    style: TextStyle(
                      fontSize: 13 * scaleX,
                      color: const Color(0x8FFFFFFF),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          SizedBox(width: 40 * scaleX), // balance the back button
        ],
      ),
    );
  }
}

// ── Step row with index number + arrow-separated path ─────────

class DetailStepRow extends StatelessWidget {
  final int index;
  final String text;
  final double scaleX;

  const DetailStepRow({
    super.key,
    required this.index,
    required this.text,
    required this.scaleX,
  });

  @override
  Widget build(BuildContext context) {
    final parts = text.split(' > ');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$index.',
          style: TextStyle(
            fontSize: 15 * scaleX,
            color: const Color(0xFFFFFFFF),
          ),
        ),
        SizedBox(width: 4 * scaleX),
        ...parts.asMap().entries.expand((entry) {
          final i = entry.key;
          final part = entry.value;
          return [
            Text(
              part,
              style: TextStyle(
                fontSize: 14 * scaleX,
                color: const Color(0xFFFFFFFF),
              ),
            ),
            if (i < parts.length - 1) ...[
              SizedBox(width: 4 * scaleX),
              Icon(
                CupertinoIcons.chevron_right,
                size: 10 * scaleX,
                color: const Color(0xFFFFFFFF),
              ),
              SizedBox(width: 4 * scaleX),
            ],
          ];
        }),
      ],
    );
  }
}

// ── Bullet point row ──────────────────────────────────────────

class DetailBulletRow extends StatelessWidget {
  final String text;
  final double scaleX;

  const DetailBulletRow({super.key, required this.text, required this.scaleX});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 13 * scaleX),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14 * scaleX,
              color: const Color(0xFFFFFFFF),
            ),
          ),
        ),
      ],
    );
  }
}

// ── "Found anomaly" action button ─────────────────────────────

class DetailAnomalyButton extends StatelessWidget {
  final double scaleX;
  final double scaleY;
  final VoidCallback onTap;

  const DetailAnomalyButton({
    super.key,
    required this.scaleX,
    required this.scaleY,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52 * scaleY,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            stops: [0.0, 0.34135, 0.65865, 1.0],
            colors: [
              Color(0x4D753434),
              Color(0x4DFF0000),
              Color(0x4DFF0000),
              Color(0x4D753434),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF27373),
            width: 0.8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'Found anomaly',
          style: TextStyle(
            fontSize: 15 * scaleX,
            color: const Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}

// ── "No anomaly found" action button ──────────────────────────

class DetailCleanButton extends StatelessWidget {
  final double scaleX;
  final double scaleY;
  final VoidCallback onTap;

  const DetailCleanButton({
    super.key,
    required this.scaleX,
    required this.scaleY,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52 * scaleY,
        decoration: BoxDecoration(
          color: const Color(0x1FD9D9D9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0x3DFFFFFF),
            width: 0.8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'No anomaly found',
          style: TextStyle(
            fontSize: 15 * scaleX,
            color: const Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}

// ── Evidence bottom sheet ─────────────────────────────────────
// Matches Figma EvidenceSheet: panel height=394, appears at top=458

class DetailEvidenceSheet extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onDismiss;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onAudio;
  final bool uploading;
  final bool isRecording;
  final double scaleX;
  final double scaleY;
  final double sh;
  final double sw;

  const DetailEvidenceSheet({
    super.key,
    required this.onClose,
    required this.onDismiss,
    required this.onCamera,
    required this.onGallery,
    required this.onAudio,
    required this.uploading,
    this.isRecording = false,
    required this.scaleX,
    required this.scaleY,
    required this.sh,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    final panelTop = 458 * scaleY;
    final panelHeight = 394 * scaleY;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Scrim — tap to dismiss without confirming
        GestureDetector(
          onTap: onDismiss,
          child: Container(
            color: const Color(0x66171717),
          ),
        ),

        // Panel background
        Positioned(
          top: panelTop,
          left: 0,
          right: 0,
          height: panelHeight,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              border: Border(
                top: BorderSide(color: Color(0xFFFFFFFF), width: 1),
                left: BorderSide(color: Color(0xFFFFFFFF), width: 1),
                right: BorderSide(color: Color(0xFFFFFFFF), width: 1),
              ),
            ),
          ).animate().slideY(begin: 1, end: 0, duration: 320.ms, curve: Curves.easeOut),
        ),

        // Content
        Positioned(
          top: panelTop,
          left: 0,
          right: 0,
          height: panelHeight,
          child: _EvidenceSheetContent(
            onClose:     onClose,
            onCamera:    onCamera,
            onGallery:   onGallery,
            onAudio:     onAudio,
            uploading:   uploading,
            isRecording: isRecording,
            scaleX:      scaleX,
            scaleY:      scaleY,
            sw:          sw,
          ).animate().slideY(begin: 1, end: 0, duration: 320.ms, curve: Curves.easeOut),
        ),
      ],
    );
  }
}

class _EvidenceSheetContent extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onAudio;
  final bool uploading;
  final bool isRecording;
  final double scaleX;
  final double scaleY;
  final double sw;

  const _EvidenceSheetContent({
    required this.onClose,
    required this.onCamera,
    required this.onGallery,
    required this.onAudio,
    required this.uploading,
    this.isRecording = false,
    required this.scaleX,
    required this.scaleY,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 40 * scaleY),

        // Title row
        Padding(
          padding: EdgeInsets.only(left: 39 * scaleX),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.bell,
                color: Color(0xFFFFFFFF),
                size: 24,
              ),
              SizedBox(width: 6 * scaleX),
              Text(
                'Found Anomaly',
                style: TextStyle(
                  fontSize: 17 * scaleX,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 8 * scaleY),

        // Subtitle
        Padding(
          padding: EdgeInsets.only(left: 68 * scaleX),
          child: Text(
            'Add screenshot as evidence (optional)',
            style: TextStyle(
              fontSize: 13 * scaleX,
              color: const Color(0xB3FFFFFF),
            ),
          ),
        ),

        SizedBox(height: 52 * scaleY),

        // Three upload option buttons
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _UploadOption(
                icon: CupertinoIcons.camera,
                label: '拍照',
                scaleX: scaleX,
                scaleY: scaleY,
                enabled: !uploading && !isRecording,
                onTap: onCamera,
              ),
              SizedBox(width: 17 * scaleX),
              _UploadOption(
                icon: CupertinoIcons.photo,
                label: '相册',
                scaleX: scaleX,
                scaleY: scaleY,
                enabled: !uploading && !isRecording,
                onTap: onGallery,
              ),
              SizedBox(width: 17 * scaleX),
              _UploadOption(
                icon: uploading
                    ? CupertinoIcons.clock
                    : isRecording
                        ? CupertinoIcons.stop_circle
                        : CupertinoIcons.mic,
                label: uploading ? '上传中' : isRecording ? '停止' : '录音',
                scaleX: scaleX,
                scaleY: scaleY,
                enabled: !uploading,
                highlight: isRecording,
                onTap: onAudio,
              ),
            ],
          ),
        ),

        SizedBox(height: 40 * scaleY),

        // "Mark as anomaly, skip upload" button
        Center(
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 67 * scaleX,
                vertical: 13 * scaleY,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0x40FFFFFF),
                  width: 0.8,
                ),
              ),
              child: Text(
                'Mark as anomaly, skip upload',
                style: TextStyle(
                  fontSize: 15 * scaleX,
                  color: const Color(0xB3FFFFFF),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Upload option button ───────────────────────────────────────

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final double scaleX;
  final double scaleY;
  final bool enabled;
  final bool highlight;
  final VoidCallback onTap;

  const _UploadOption({
    required this.icon,
    required this.label,
    required this.scaleX,
    required this.scaleY,
    required this.onTap,
    this.enabled = true,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? const Color(0xFFEF4444) : const Color(0xFFFFFFFF);
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 105 * scaleX,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 42 * scaleX, color: color),
              SizedBox(height: 8 * scaleY),
              Text(
                label,
                style: TextStyle(fontSize: 20 * scaleX, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
