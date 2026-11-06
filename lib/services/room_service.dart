import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/joined_room.dart';
import '../utils/room_code.dart';

class RoomNotFoundException implements Exception {
  const RoomNotFoundException(this.code);
  final String code;
}

class RoomService {
  RoomService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection('rooms');

  Future<bool> roomExists(String code) async {
    final doc = await _rooms.doc(code).get();
    return doc.exists;
  }

  Future<String> createRoom({int maxAttempts = 5}) async {
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final code = generateRoomCode();
      final ref = _rooms.doc(code);
      final snapshot = await ref.get();
      if (snapshot.exists) continue;
      await ref.set({'code': code, 'createdAt': FieldValue.serverTimestamp()});
      return code;
    }
    throw StateError('Could not generate a unique room code, please retry.');
  }

  Future<void> assertRoomExists(String code) async {
    if (!await roomExists(code)) {
      throw RoomNotFoundException(code);
    }
  }

  Future<void> addMember({
    required String roomCode,
    required String uid,
    required String displayName,
  }) {
    return _rooms.doc(roomCode).collection('members').doc(uid).set({
      'uid': uid,
      'displayName': displayName,
      'joinedAt': FieldValue.serverTimestamp(),
      'lastVisitedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> touchMember({
    required String roomCode,
    required String uid,
    required String displayName,
  }) {
    return _rooms.doc(roomCode).collection('members').doc(uid).set({
      'uid': uid,
      'displayName': displayName,
      'lastVisitedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setTyping({
    required String roomCode,
    required String uid,
    required bool isTyping,
  }) {
    return _rooms.doc(roomCode).collection('members').doc(uid).set({
      'uid': uid,
      'isTyping': isTyping,
      'typingAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<String>> typingMembersStream({
    required String roomCode,
    required String excludeUid,
    Duration staleAfter = const Duration(seconds: 6),
  }) {
    return _rooms.doc(roomCode).collection('members').snapshots().map((
      snapshot,
    ) {
      final now = DateTime.now();
      return snapshot.docs
          .map((doc) => doc.data())
          .where((data) {
            if (data['uid'] == excludeUid) return false;
            if (data['isTyping'] != true) return false;
            final typingAt = (data['typingAt'] as Timestamp?)?.toDate();
            if (typingAt == null) return false;
            return now.difference(typingAt) <= staleAfter;
          })
          .map((data) => data['displayName'] as String? ?? 'Someone')
          .toList();
    });
  }

  Stream<int> memberCountStream(String roomCode) {
    return _rooms
        .doc(roomCode)
        .collection('members')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<List<JoinedRoom>> joinedRoomsStream(String uid) {
    return _firestore
        .collectionGroup('members')
        .where('uid', isEqualTo: uid)
        .orderBy('lastVisitedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            final roomCode = doc.reference.parent.parent!.id;
            final lastVisitedAt = (data['lastVisitedAt'] as Timestamp?)
                    ?.toDate() ??
                DateTime.now();
            return JoinedRoom(
              roomCode: roomCode,
              displayName: data['displayName'] as String? ?? 'Unknown',
              lastVisitedAt: lastVisitedAt,
            );
          }).toList(),
        );
  }
}
