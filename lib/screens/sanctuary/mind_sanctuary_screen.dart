import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/deepseek_service.dart';

// MindSanctuary — AI内心对话界面
// Two views: landing (card stack) → chat (frosted glass messages)
class MindSanctuaryScreen extends StatefulWidget {
  final VoidCallback onBack;

  const MindSanctuaryScreen({super.key, required this.onBack});

  @override
  State<MindSanctuaryScreen> createState() => _MindSanctuaryScreenState();
}

class _MindSanctuaryScreenState extends State<MindSanctuaryScreen> {
  _SanctuaryView _view = _SanctuaryView.landing;
  final List<_Message> _messages = [];
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  String? _activeCategory;
  bool _aiThinking = false;

  static const _categories = [
    _Category(
      id: 'guilt',
      title: '我很愧疚',
      sub: '我不知道该怎么面对这件事',
      ai: '你现在的状态，可能有点复杂。如果你愿意，可以告诉我最近发生了什么。',
      bgColor: Color(0xFFD1D5DB),
      textColor: Color(0xFF000000),
      subColor: Color(0x80000000),
      tiltDeg: -1.2,
      zOrder: 30,
    ),
    _Category(
      id: 'complex',
      title: '事情变得复杂了',
      sub: '我不知道该怎么处理现在的关系',
      ai: '关系中的复杂往往源于未被察觉的信号。我们可以从理性的角度分析现状。',
      bgColor: Color(0xFF262626),
      textColor: Color(0xE5FFFFFF),
      subColor: Color(0x4DFFFFFF),
      tiltDeg: 1.8,
      zOrder: 20,
      extraTopPadding: 24,
    ),
    _Category(
      id: 'occurred',
      title: '也许事情已经发生了',
      sub: '我想弄清楚自己真正的想法',
      ai: '既然已经发生，与其回望，不如探索你内心真正的倾向。你现在的感受是什么？',
      bgColor: Color(0xFFE2FB5E),
      textColor: Color(0xFF000000),
      subColor: Color(0x80000000),
      tiltDeg: -1.0,
      zOrder: 10,
      extraTopPadding: 48,
    ),
  ];

  static const _chips = ['我不知道该说什么', '我怕被发现', '我不知道怎么办'];

  void _startChat(String categoryId, String aiMessage) {
    setState(() {
      _activeCategory = categoryId;
      _messages.clear();
      _view = _SanctuaryView.chat;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_Message(
          id: '1',
          role: _Role.ai,
          text: aiMessage,
        ));
      });
    });
  }

  String get _systemPrompt {
    switch (_activeCategory) {
      case 'guilt':
        return 'You are a warm, empathetic companion helping someone process feelings of guilt in a relationship. '
            'Respond with compassion, avoid judgment, speak in Chinese, keep replies concise (2-4 sentences).';
      case 'complex':
        return 'You are a calm, analytical relationship counselor helping someone navigate a complicated relationship situation. '
            'Offer thoughtful, rational perspective, speak in Chinese, keep replies concise (2-4 sentences).';
      case 'occurred':
        return 'You are a gentle therapist helping someone understand their true feelings after something has happened in their relationship. '
            'Encourage self-reflection, speak in Chinese, keep replies concise (2-4 sentences).';
      default:
        return 'You are a compassionate AI companion for emotional support in relationship situations. '
            'Respond warmly and supportively in Chinese, keep replies concise (2-4 sentences).';
    }
  }

  Future<void> _handleSend([String? text]) async {
    final content = (text ?? _inputController.text).trim();
    if (content.isEmpty || _aiThinking) return;

    setState(() {
      _messages.add(_Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: _Role.user,
        text: content,
      ));
      _inputController.clear();
      _aiThinking = true;
    });

    _scrollToBottom();

    // Build history for DeepSeek (exclude the initial AI greeting to save tokens)
    final history = _messages
        .map((m) => ChatMessage(
              role: m.role == _Role.user ? 'user' : 'assistant',
              content: m.text,
            ))
        .toList();

    try {
      final reply = await DeepSeekService.chat(
        history:      history,
        systemPrompt: _systemPrompt,
      );
      if (!mounted) return;
      setState(() {
        _aiThinking = false;
        _messages.add(_Message(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          role: _Role.ai,
          text: reply,
        ));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _aiThinking = false;
        _messages.add(_Message(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          role: _Role.ai,
          text: '连接出现了问题，请稍后再试。',
        ));
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _view == _SanctuaryView.landing ? _buildLanding() : _buildChat();
  }

  // ── Landing page ─────────────────────────────────────────────

  Widget _buildLanding() {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0E0E10),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    CupertinoButton(
                      padding: const EdgeInsets.only(bottom: 32),
                      onPressed: widget.onBack,
                      child: const Icon(
                        CupertinoIcons.chevron_left,
                        size: 24,
                        color: Color(0x4DFFFFFF),
                      ),
                    ),

                    // Header
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFFFFFFFF),
                          height: 1.3,
                        ),
                        children: [
                          TextSpan(text: '整理一下你的\n'),
                          TextSpan(
                            text: '想法',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 12),
                    const Text(
                      'Inner Sanctuary',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0x33FFFFFF),
                        letterSpacing: 8,
                        fontWeight: FontWeight.w300,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms),
                    const SizedBox(height: 48),

                    // Stacked category cards — each card overlaps the previous
                    // by its extraTopPadding (matches Figma translate-y negative)
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.88,
                      child: Column(
                        children: _categories.asMap().entries.map((entry) {
                          final i = entry.key;
                          final cat = entry.value;
                          return Transform.translate(
                            offset: Offset(0, -cat.extraTopPadding),
                            child: _CategoryCard(
                              category: cat,
                              index: i,
                              onTap: () => _startChat(cat.id, cat.ai),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Quick chips
                    const SizedBox(height: 64),
                    const Text(
                      '快速整理',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0x33FFFFFF),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _chips.map((chip) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => _startChat(
                                  'general', '关于"$chip"，你有什么想说的吗？'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0x0AFFFFFF),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      color: const Color(0x0DFFFFFF)),
                                ),
                                child: Text(
                                  chip,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0x66FFFFFF),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Chat page ─────────────────────────────────────────────────

  Widget _buildChat() {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/evidence_bg.jpg',
            fit: BoxFit.cover,
          ),
          // Frosted glass: blur + dark tint (matches Figma backdrop-blur-sm bg-black/30)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: const Color(0x4D000000)),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x66000000), Color(0x00000000), Color(0x99000000)],
                stops: [0, 0.5, 1],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () =>
                            setState(() => _view = _SanctuaryView.landing),
                        child: const Icon(
                          CupertinoIcons.chevron_left,
                          size: 24,
                          color: Color(0xB3FFFFFF),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          '聊天室',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),

                // Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) =>
                        _MessageBubble(message: _messages[i]),
                  ),
                ),

                // Input area
                _ChatInput(
                  controller: _inputController,
                  onSend: _handleSend,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────

enum _SanctuaryView { landing, chat }

enum _Role { ai, user }

class _Message {
  final String id;
  final _Role role;
  final String text;

  const _Message({required this.id, required this.role, required this.text});
}

class _Category {
  final String id;
  final String title;
  final String sub;
  final String ai;
  final Color bgColor;
  final Color textColor;
  final Color subColor;
  final double tiltDeg;
  final int zOrder;
  final double extraTopPadding;

  const _Category({
    required this.id,
    required this.title,
    required this.sub,
    required this.ai,
    required this.bgColor,
    required this.textColor,
    required this.subColor,
    required this.tiltDeg,
    required this.zOrder,
    this.extraTopPadding = 0,
  });
}

// ── Category card (stacked, tilted) ──────────────────────────

class _CategoryCard extends StatelessWidget {
  final _Category category;
  final int index;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: category.tiltDeg * 3.14159 / 180,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          width: double.infinity,
          height: 126,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: category.bgColor,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: category.textColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                category.sub,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: category.subColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 120), duration: 700.ms)
        .slideY(begin: 0.3, end: 0, curve: const Cubic(0.23, 1, 0.32, 1));
  }
}

// ── Message bubble ────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final _Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAI = message.role == _Role.ai;

    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Row(
        mainAxisAlignment:
            isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.85,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Gradient border ring
                Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(48),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isAI
                          ? const [
                              Color(0xB3FFFFFF),
                              Color(0x26FFFFFF),
                              Color(0x80FFFFFF),
                            ]
                          : const [
                              Color(0xCCFB923C),
                              Color(0x33FCD34D),
                              Color(0x99FB923C),
                            ],
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: isAI
                          ? const Color(0x26000000)
                          : const Color(0x1A000000),
                      borderRadius: BorderRadius.circular(46),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 15,
                        color: isAI
                            ? const Color(0xE5FFFFFF)
                            : const Color(0xFFFFFFFF),
                        height: 1.6,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),

                // Tail dots
                Positioned(
                  bottom: -10,
                  left: isAI ? -16 : null,
                  right: isAI ? null : -16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isAI)
                        _TailDot(size: 8, topMargin: 8),
                      _TailDot(size: 16),
                      if (isAI)
                        _TailDot(size: 8, topMargin: 8),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.9, 0.9))
              .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

class _TailDot extends StatelessWidget {
  final double size;
  final double topMargin;

  const _TailDot({required this.size, this.topMargin = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topMargin),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
      ),
    );
  }
}

// ── Chat input area ───────────────────────────────────────────

class _ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final void Function([String?]) onSend;

  const _ChatInput({required this.controller, required this.onSend});

  @override
  State<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<_ChatInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      final has = widget.controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xCC000000), Color(0x00000000)],
        ),
      ),
      child: Column(
        children: [
          // Quota row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 11, color: Color(0x4DFFFFFF)),
                  children: [
                    TextSpan(text: '剩余 '),
                    TextSpan(
                      text: '200',
                      style: TextStyle(color: Color(0x80FFFFFF)),
                    ),
                    TextSpan(text: ' 对话额度'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: const LinearGradient(
                    colors: [Color(0x66FFFFFF), Color(0x1AFFFFFF), Color(0x4DFFFFFF)],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x33000000),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    '升级',
                    style: TextStyle(fontSize: 11, color: Color(0x99FFFFFF)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Input box
          Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(48),
              gradient: const LinearGradient(
                colors: [Color(0x4DFFFFFF), Color(0x1AFFFFFF), Color(0x66FFFFFF)],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x66000000),
                borderRadius: BorderRadius.circular(47),
              ),
              child: Row(
                children: [
                  // Mic button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0x0DFFFFFF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x1AFFFFFF)),
                    ),
                    child: const Icon(
                      CupertinoIcons.mic,
                      size: 20,
                      color: Color(0x66FFFFFF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Text field
                  Expanded(
                    child: CupertinoTextField(
                      controller: widget.controller,
                      placeholder: '轻轻诉说你的想法...',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWeight.w300,
                      ),
                      placeholderStyle: const TextStyle(
                        fontSize: 15,
                        color: Color(0x33FFFFFF),
                      ),
                      decoration: null,
                      maxLines: 4,
                      minLines: 1,
                      onSubmitted: (_) => widget.onSend(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Send button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _hasText
                          ? const Color(0xE5FFFFFF)
                          : const Color(0x1AFFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _hasText ? widget.onSend : null,
                      child: Icon(
                        CupertinoIcons.arrow_up,
                        size: 16,
                        color: _hasText
                            ? const Color(0xFF000000)
                            : const Color(0x33FFFFFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
