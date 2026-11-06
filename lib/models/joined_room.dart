import 'room_identity.dart';

class JoinedRoom {
  const JoinedRoom({
    required this.roomCode,
    required this.displayName,
    required this.lastVisitedAt,
  });

  final String roomCode;
  final String displayName;
  final DateTime lastVisitedAt;

  RoomIdentity get identity =>
      RoomIdentity(roomCode: roomCode, displayName: displayName);
}
