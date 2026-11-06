import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../models/chat_message.dart';
import '../models/room_identity.dart';
import '../services/active_room_tracker.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/room_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/date_separator.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/typing_indicator.dart';

sealed class _ChatListItem {}

class _MessageItem extends _ChatListItem {
  _MessageItem(this.message);
  final ChatMessage message;
}

class _SeparatorItem extends _ChatListItem {
  _SeparatorItem(this.label);
  final String label;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.roomCode, required this.identity});

  final String roomCode;
  final RoomIdentity identity;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Map<String, MessageDoc> _docsById = {};
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  StreamSubscription<List<MessageDoc>>? _subscription;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _sending = false;

  Timer? _typingIdleTimer;
  bool _isTypingFlagSet = false;

  late final ChatService _chatService;
  late final RoomService _roomService;
  late final ActiveRoomTracker _activeRoomTracker;
  late final String? _uid;

  @override
  void initState() {
    super.initState();
    _chatService = context.read<ChatService>();
    _roomService = context.read<RoomService>();
    _activeRoomTracker = context.read<ActiveRoomTracker>();
    _uid = context.read<AuthService>().uid;

    _activeRoomTracker.setActive(widget.roomCode);

    final uid = _uid;
    if (uid != null) {
      _roomService.touchMember(
        roomCode: widget.roomCode,
        uid: uid,
        displayName: widget.identity.displayName,
      );
    }
    _subscription = _chatService
        .latestMessagesStream(widget.roomCode)
        .listen((docs) {
          if (!mounted) return;
          setState(() {
            for (final doc in docs) {
              _docsById[doc.id] = doc;
            }
          });
        });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _clearTyping();
    _activeRoomTracker.clear(widget.roomCode);
    _subscription?.cancel();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  int _timeOf(MessageDoc doc) {
    final ts = doc.data()['createdAt'] as Timestamp?;
    return ts?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
  }

  List<MessageDoc> get _sortedDocsDesc {
    final list = _docsById.values.toList();
    list.sort((a, b) => _timeOf(b).compareTo(_timeOf(a)));
    return list;
  }

  void _onScroll() {
    if (_loadingMore || !_hasMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final docs = _sortedDocsDesc;
    if (docs.isEmpty) return;
    setState(() => _loadingMore = true);
    try {
      final older = await _chatService.fetchOlderMessages(
        roomCode: widget.roomCode,
        before: docs.last,
      );
      if (!mounted) return;
      setState(() {
        for (final doc in older) {
          _docsById[doc.id] = doc;
        }
        if (older.length < ChatService.pageSize) _hasMore = false;
      });
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _onTextChanged(String _) {
    final uid = _uid;
    if (uid == null) return;
    if (!_isTypingFlagSet) {
      _isTypingFlagSet = true;
      _roomService.setTyping(
        roomCode: widget.roomCode,
        uid: uid,
        isTyping: true,
      );
    }
    _typingIdleTimer?.cancel();
    _typingIdleTimer = Timer(const Duration(seconds: 4), _clearTyping);
  }

  void _clearTyping() {
    _typingIdleTimer?.cancel();
    if (!_isTypingFlagSet) return;
    _isTypingFlagSet = false;
    final uid = _uid;
    if (uid != null) {
      _roomService.setTyping(
        roomCode: widget.roomCode,
        uid: uid,
        isTyping: false,
      );
    }
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _sending) return;
    _textController.clear();
    _clearTyping();
    setState(() => _sending = true);
    try {
      await _chatService.sendMessage(
        roomCode: widget.roomCode,
        text: text,
        senderUid: _uid ?? '',
        senderName: widget.identity.displayName,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _copyRoomLink() async {
    final link = 'rumour://room/${widget.roomCode}';
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Room link copied: $link')),
    );
  }

  List<_ChatListItem> _buildItems(List<MessageDoc> descDocs) {
    final items = <_ChatListItem>[];
    for (var i = 0; i < descDocs.length; i++) {
      final doc = descDocs[i];
      final message = ChatMessage.fromDoc(doc);
      items.add(_MessageItem(message));

      final currentDate = message.createdAt ?? DateTime.now();
      final next = i + 1 < descDocs.length ? descDocs[i + 1] : null;
      final isLastOfDay =
          next == null ||
          !isSameDay(
            currentDate,
            ChatMessage.fromDoc(next).createdAt ?? DateTime.now(),
          );
      if (isLastOfDay) {
        items.add(_SeparatorItem(formatDateSeparator(currentDate)));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = _buildItems(_sortedDocsDesc);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
        title: Column(
          children: [
            Text(
              'Room #${widget.roomCode}',
              style: AppTextStyles.headerTitle(colors),
            ),
            StreamBuilder<int>(
              stream: _roomService.memberCountStream(widget.roomCode),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 1;
                return Text(
                  '$count member${count == 1 ? '' : 's'}',
                  style: AppTextStyles.headerSubtitle(colors),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.link_rounded, color: colors.textPrimary),
            tooltip: 'Copy room link',
            onPressed: _copyRoomLink,
          ),
          const ThemeToggleButton(),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colors.surface,
              child: Text(
                widget.identity.displayName.isNotEmpty
                    ? widget.identity.displayName[0]
                    : '?',
                style: TextStyle(
                  color: colors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet. Say hi!',
                        style: AppTextStyles.subtitle(colors),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: items.length + (_loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_loadingMore && index == items.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.accent,
                                ),
                              ),
                            ),
                          );
                        }
                        final item = items[index];
                        if (item is _SeparatorItem) {
                          return DateSeparator(label: item.label);
                        }
                        final message = (item as _MessageItem).message;
                        final isOwn = message.senderUid == _uid;
                        return ChatBubble(
                          key: ValueKey(message.id),
                          message: message,
                          isOwnMessage: isOwn,
                          senderHandle: isOwn
                              ? 'You'
                              : '@${message.senderName.replaceAll(' ', '')}',
                        );
                      },
                    ),
            ),
            if (_uid != null)
              StreamBuilder<List<String>>(
                stream: _roomService.typingMembersStream(
                  roomCode: widget.roomCode,
                  excludeUid: _uid,
                ),
                builder: (context, snapshot) {
                  return TypingIndicator(names: snapshot.data ?? const []);
                },
              ),
            _buildInputBar(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                controller: _textController,
                style: TextStyle(color: colors.textPrimary),
                textInputAction: TextInputAction.send,
                onChanged: _onTextChanged,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  hintStyle: TextStyle(color: colors.textSecondary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          PressableScale(
            enabled: !_sending,
            onTap: _send,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send_rounded, color: colors.onAccent, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
