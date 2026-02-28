import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/investigation_provider.dart';

// ArchiveAccess — password gate before entering historical records
class ArchiveAccessScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSuccess;

  const ArchiveAccessScreen({
    super.key,
    required this.onBack,
    required this.onSuccess,
  });

  @override
  ConsumerState<ArchiveAccessScreen> createState() =>
      _ArchiveAccessScreenState();
}

class _ArchiveAccessScreenState extends ConsumerState<ArchiveAccessScreen> {
  _LockState _lockState = _LockState.input;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _error;

  @override
  void initState() {
    super.initState();
    // Delay focus request until after the entry animations finish (400ms),
    // so keyboard doesn't interrupt the first frame layout.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  Future<void> _handleConfirm() async {
    final passphrase = _controller.text.trim();
    if (passphrase.isEmpty) return;
    setState(() => _error = null);

    final found = await ref
        .read(investigationProvider.notifier)
        .load(passphrase);

    if (!mounted) return;
    if (found) {
      setState(() => _lockState = _LockState.unlocked);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) widget.onSuccess();
      });
    } else {
      setState(() => _error = 'Incorrect key or no record found.');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF050505),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _AccessBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header — back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: widget.onBack,
                      child: const Icon(CupertinoIcons.chevron_left,
                          size: 24, color: Color(0x99FFFFFF)),
                    ),
                  ),
                ),

                // Content centered
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _lockState == _LockState.input
                          ? _InputView(
                              controller: _controller,
                              focusNode: _focusNode,
                              onConfirm: _handleConfirm,
                              errorText: _error,
                            )
                          : const _UnlockedView(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _LockState { input, unlocked }

// ── Background ────────────────────────────────────────────────

class _AccessBackground extends StatelessWidget {
  const _AccessBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF050505)),
        // Subtle radial from top-left
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-1.0, -1.0),
              radius: 1.5,
              colors: [Color(0x05FFFFFF), Color(0x00000000)],
            ),
          ),
        ),
        // Top divider line
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 1,
          child: ColoredBox(color: Color(0x0DFFFFFF)),
        ),
      ],
    );
  }
}

// ── Input view ────────────────────────────────────────────────

class _InputView extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onConfirm;
  final String? errorText;

  const _InputView({
    required this.controller,
    required this.focusNode,
    required this.onConfirm,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lock icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0x05FFFFFF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: const Icon(
              CupertinoIcons.lock,
              size: 32,
              color: Color(0x66FFFFFF),
            ),
          )
              .animate()
              .scale(begin: const Offset(0.95, 0.95), duration: 400.ms)
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 24),

          const Text(
            '历史观察报告',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Color(0xE5FFFFFF),
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 8),
          const Text(
            '安全保护 / 加密存储',
            style: TextStyle(
              fontSize: 11,
              color: Color(0x4DFFFFFF),
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 400.ms),
          const SizedBox(height: 40),

          // Password field
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              CupertinoTextField(
                controller: controller,
                focusNode: focusNode,
                obscureText: true,
                textAlign: TextAlign.center,
                placeholder: '档案访问密钥',
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 20,
                  fontFamily: 'Courier',
                  letterSpacing: 10,
                ),
                placeholderStyle: const TextStyle(
                  color: Color(0x1AFFFFFF),
                  fontSize: 16,
                  fontFamily: 'Courier',
                  letterSpacing: 1,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0x08FFFFFF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x1AFFFFFF)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 24),
                child: Icon(
                  CupertinoIcons.doc_on_doc,
                  size: 20,
                  color: Color(0x0DFFFFFF),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // Unlock button
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onConfirm,
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1AFFFFFF),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  )
                ],
              ),
              child: const Center(
                child: Text(
                  '解锁并进入',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms),

          if (errorText != null) ...[
            const SizedBox(height: 12),
            Text(
              errorText!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFEF4444),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 40),

          // Security badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _SecurityBadge(icon: CupertinoIcons.viewfinder, label: '安全扫描'),
              Container(
                width: 1,
                height: 32,
                color: const Color(0x0DFFFFFF),
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),
              const _SecurityBadge(
                  icon: CupertinoIcons.shield, label: '端对端加密'),
            ],
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SecurityBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.20,
      child: Column(
        children: [
          Icon(icon, size: 16, color: const Color(0xFFFFFFFF)),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFFFFFFFF),
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Unlocked success view ─────────────────────────────────────

class _UnlockedView extends StatelessWidget {
  const _UnlockedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0x1A10B981),
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.3, 1.3),
                    duration: 1000.ms,
                  )
                  .fadeOut(duration: 1000.ms),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0x1A10B981),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x3310B981)),
                ),
                child: const Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  size: 40,
                  color: Color(0xFF34D399),
                ),
              ),
            ],
          )
              .animate()
              .scale(begin: const Offset(0.95, 0.95), duration: 400.ms)
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          const Text(
            '访问已授权',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Color(0xFFD1FAE5),
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 8),
          const Text(
            '身份验证成功，正在提取历史记录...',
            style: TextStyle(
              fontSize: 12,
              color: Color(0x9934D399),
              fontWeight: FontWeight.w300,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.lock,
                  size: 12, color: Color(0x6610B981)),
              SizedBox(width: 8),
              Text(
                'Key Hash Verified',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0x9910B981),
                  fontFamily: 'Courier',
                  letterSpacing: 4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms),
        ],
      ),
    );
  }
}
