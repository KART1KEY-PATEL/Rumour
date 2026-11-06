import 'dart:async';

import '../models/chat_message.dart';
import '../models/joined_room.dart';
import 'active_room_tracker.dart';
import 'chat_service.dart';
import 'notification_service.dart';
import 'room_service.dart';

class MessageWatcherService {
  MessageWatcherService({
    required RoomService roomService,
    required ChatService chatService,
    required NotificationService notificationService,
    required ActiveRoomTracker activeRoomTracker,
  }) : _roomService = roomService,
       _chatService = chatService,
       _notificationService = notificationService,
       _activeRoomTracker = activeRoomTracker;

  final RoomService _roomService;
  final ChatService _chatService;
  final NotificationService _notificationService;
  final ActiveRoomTracker _activeRoomTracker;

  StreamSubscription<List<JoinedRoom>>? _roomsSubscription;
  final Map<String, StreamSubscription<MessageDoc?>> _messageSubscriptions =
      {};
  final Map<String, String?> _lastSeenMessageId = {};
  String? _myUid;

  void start(String uid) {
    _myUid = uid;
    _roomsSubscription = _roomService.joinedRoomsStream(uid).listen((rooms) {
      final currentCodes = rooms.map((r) => r.roomCode).toSet();

      final removed = _messageSubscriptions.keys
          .where((code) => !currentCodes.contains(code))
          .toList();
      for (final code in removed) {
        _messageSubscriptions.remove(code)?.cancel();
        _lastSeenMessageId.remove(code);
      }

      for (final code in currentCodes) {
        if (_messageSubscriptions.containsKey(code)) continue;
        _lastSeenMessageId[code] = null;
        _messageSubscriptions[code] = _chatService
            .latestSingleMessageStream(code)
            .listen((doc) => _onLatestMessage(code, doc));
      }
    });
  }

  void _onLatestMessage(String roomCode, MessageDoc? doc) {
    if (doc == null) return;
    final previousId = _lastSeenMessageId[roomCode];
    _lastSeenMessageId[roomCode] = doc.id;

    if (previousId == null) return;
    if (doc.id == previousId) return;

    final message = ChatMessage.fromDoc(doc);
    if (message.senderUid == _myUid) return;
    if (_activeRoomTracker.activeRoomCode == roomCode) return;

    _notificationService.showMessageNotification(
      roomCode: roomCode,
      senderHandle: '@${message.senderName.replaceAll(' ', '')}',
      text: message.text,
    );
  }

  void dispose() {
    _roomsSubscription?.cancel();
    for (final sub in _messageSubscriptions.values) {
      sub.cancel();
    }
    _messageSubscriptions.clear();
  }
}
