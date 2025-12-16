// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maduro/aichatbot/aichatbot.dart';

class AIChatBotScreen extends StatefulWidget {
  const AIChatBotScreen({super.key});

  @override
  _AIChatBotScreenState createState() => _AIChatBotScreenState();
}

class _AIChatBotScreenState extends State<AIChatBotScreen>
    with TickerProviderStateMixin {
  final AIChatBotService _chatBotService = AIChatBotService();
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  late AnimationController _typingAnimationController;
  late AnimationController _sendButtonController;

  // Modern Green-Yellow Color Palette
  static const Color primaryGreen = Color(0xFF10B981); // Emerald green
  static const Color accentYellow = Color(0xFFF59E0B); // Amber yellow
  static const Color lightGreen = Color(0xFFECFDF5); // Light green background
  static const Color darkGreen = Color(0xFF064E3B); // Dark green text
  static const Color neutralGray = Color(0xFF6B7280); // Modern gray
  static const Color lightGray = Color(0xFFF9FAFB); // Very light gray
  static const Color white = Color(0xFFFFFFFF);
  static const Color gradientStart = Color(0xFF34D399); // Light green
  static const Color gradientEnd = Color(0xFF10B981); // Emerald

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _typingAnimationController.dispose();
    _sendButtonController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String userInput) async {
    if (userInput.trim().isEmpty || _isSending) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _messages.insert(0, ChatMessage(text: userInput, isUser: true));
      _isSending = true;
    });

    _sendButtonController.forward().then((_) {
      _sendButtonController.reverse();
    });

    final response = await _chatBotService.sendMessage(userInput);

    setState(() {
      _messages.insert(0, ChatMessage(text: response, isUser: false));
      _isSending = false;
    });

    // Auto-scroll to bottom
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSendMessage() {
    if (_controller.text.trim().isNotEmpty && !_isSending) {
      _sendMessage(_controller.text.trim());
      _controller.clear();
    }
  }

  void _handleSuggestionChipTap(String suggestion) {
    // Remove emoji and extra formatting from suggestion
    String cleanSuggestion = suggestion.replaceAll(RegExp(r'[🌡️🍊🕒]\s*'), '');
    _controller.text = cleanSuggestion;
    _handleSendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: _buildModernAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Typing indicator with modern animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isSending ? 60 : 0,
              child: _isSending
                  ? _buildTypingIndicator()
                  : const SizedBox.shrink(),
            ),

            // Chat messages
            Expanded(
              child: _messages.isEmpty
                  ? _buildModernEmptyState()
                  : ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          curve: Curves.easeOut,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildModernMessageBubble(message),
                          ),
                        );
                      },
                    ),
            ),

            // Modern message input area
            _buildModernInputArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: white,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [gradientStart, gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Fruit Assistant',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: darkGreen,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Always ready to help',
                  style: TextStyle(
                    fontSize: 12,
                    color: neutralGray,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: primaryGreen,
                size: 20,
              ),
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [gradientStart, gradientEnd],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _typingAnimationController,
            builder: (context, child) {
              return Row(
                children: List.generate(3, (index) {
                  final delay = index * 0.3;
                  final animation = Tween<double>(begin: 0.4, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _typingAnimationController,
                      curve:
                          Interval(delay, delay + 0.4, curve: Curves.easeInOut),
                    ),
                  );
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(animation.value),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  );
                }),
              );
            },
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Text(
              "AI is thinking...",
              style: TextStyle(
                color: neutralGray,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMessageBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(
        left: message.isUser ? 48.0 : 0,
        right: message.isUser ? 0 : 48.0,
      ),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [gradientStart, gradientEnd],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology_outlined,
                color: white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? const LinearGradient(
                        colors: [accentYellow, Color(0xFFF97316)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: message.isUser ? null : white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: message.isUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: message.isUser
                        ? accentYellow.withOpacity(0.3)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: message.isUser ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? white : darkGreen,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [accentYellow, Color(0xFFF97316)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: accentYellow.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: lightGray,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      minLines: 1,
                      style: const TextStyle(
                        fontSize: 16,
                        color: darkGreen,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Ask me anything...',
                        hintStyle: TextStyle(
                          color: neutralGray,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(20, 16, 16, 16),
                      ),
                      onSubmitted: (value) => _handleSendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: lightGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.attach_file_rounded,
                        color: primaryGreen,
                        size: 18,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _sendButtonController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 - (_sendButtonController.value * 0.1),
                child: GestureDetector(
                  onTap: _handleSendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [gradientStart, gradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(white),
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: white,
                            size: 20,
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModernEmptyState() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    lightGreen,
                    lightGreen.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [gradientStart, gradientEnd],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  size: 48,
                  color: white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Let's start chatting!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: darkGreen,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "I'm here to help you with questions about fruits. What's on your mind?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: neutralGray,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            _buildSuggestionChips(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = [
      "🌡️ Best storage conditions for this fruit?",
      "🍊 How to tell if a fruit is overripe?",
      "🕒 How long until this fruit spoils?",
    ];

    return Column(
      children: suggestions.map((suggestion) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _handleSuggestionChipTap(suggestion),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: lightGreen,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                suggestion,
                style: const TextStyle(
                  color: primaryGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
