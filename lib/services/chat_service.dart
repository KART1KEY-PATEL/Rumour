import 'package:cloud_firestore/cloud_firestore.dart';

typedef MessageDoc = QueryDocumentSnapshot<Map<String, dynamic>>;

class ChatService {
  ChatService(this._firestore);

  final FirebaseFirestore _firestore;

  static const int pageSize = 30;

  CollectionReference<Map<String, dynamic>> _messages(String roomCode) =>
      _firestore.collection('rooms').doc(roomCode).collection('messages');

  Future<void> sendMessage({
    required String roomCode,
    required String text,
    required String senderUid,
    required String senderName,
  }) {
    return _messages(roomCode).add({
      'text': text,
      'senderUid': senderUid,
      'senderName': senderName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<MessageDoc>> latestMessagesStream(String roomCode) {
    return _messages(roomCode)
        .orderBy('createdAt', descending: true)
        .limit(pageSize)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) => snapshot.docs);
  }

  Stream<MessageDoc?> latestSingleMessageStream(String roomCode) {
    return _messages(roomCode)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isEmpty ? null : snapshot.docs.first);
  }

  Future<List<MessageDoc>> fetchOlderMessages({
    required String roomCode,
    required MessageDoc before,
  }) async {
    final snapshot = await _messages(roomCode)
        .orderBy('createdAt', descending: true)
        .startAfterDocument(before)
        .limit(pageSize)
        .get();
    return snapshot.docs;
  }
}
