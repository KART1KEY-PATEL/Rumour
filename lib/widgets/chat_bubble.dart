import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/chat_message.dart';
import '../utils/date_formatter.dart';

/// Renders one message bubble with a one-shot fade+slide-in the first time
/// its [State] is created. Callers must key each instance by
/// `ValueKey(message.id)` so already-seen messages aren't re-animated every
/// time the surrounding list rebuilds on a new arrival.
class ChatBubble extends StatefulWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isOwnMessage,
    required this.senderHandle,
  });

  final ChatMessage message;
  final bool isOwnMessage;

  /// "@Handle" for incoming, "You" for outgoing.
  final String senderHandle;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  )..forward();
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide =
      Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
        _fade,
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final message = widget.message;
    final isOwnMessage = widget.isOwnMessage;

    final alignment = isOwnMessage
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final bubbleColor = isOwnMessage ? colors.accent : colors.bubbleIncoming;
    final textStyle = isOwnMessage
        ? AppTextStyles.outgoingMessageText(colors)
        : AppTextStyles.messageText(colors);
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isOwnMessage ? 18 : 4),
      bottomRight: Radius.circular(isOwnMessage ? 4 : 18),
    );

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            crossAxisAlignment: alignment,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
                child: Text(
                  widget.senderHandle,
                  style: AppTextStyles.senderLabel(colors),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: radius,
                  ),
                  child: Text(message.text, style: textStyle),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                child: Text(
                  formatMessageTime(message.createdAt),
                  style: AppTextStyles.timestamp(colors),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
