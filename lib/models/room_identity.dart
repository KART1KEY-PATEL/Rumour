class RoomIdentity {
  const RoomIdentity({required this.roomCode, required this.displayName});

  final String roomCode;

  final String displayName;

  String get handle => '@${displayName.replaceAll(' ', '')}';

  Map<String, String> toJson() => {
    'roomCode': roomCode,
    'displayName': displayName,
  };

  factory RoomIdentity.fromJson(Map<String, dynamic> json) => RoomIdentity(
    roomCode: json['roomCode'] as String,
    displayName: json['displayName'] as String,
  );
}
