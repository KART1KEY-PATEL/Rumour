import 'package:flutter/foundation.dart';

class ActiveRoomTracker extends ChangeNotifier {
  String? _activeRoomCode;
  String? get activeRoomCode => _activeRoomCode;

  void setActive(String roomCode) {
    _activeRoomCode = roomCode;
    notifyListeners();
  }

  void clear(String roomCode) {
    if (_activeRoomCode == roomCode) {
      _activeRoomCode = null;
      notifyListeners();
    }
  }
}
