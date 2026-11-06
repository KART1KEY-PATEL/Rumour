import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.text,
    required this.senderUid,
    required this.senderName,
    required this.createdAt,
    required this.hasPendingWrites,
  });

  final String id;
  final String text;
  final String senderUid;
  final String senderName;
  final DateTime? createdAt;
  final bool hasPendingWrites;

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final timestamp = data['createdAt'] as Timestamp?;
    return ChatMessage(
      id: doc.id,
      text: data['text'] as String? ?? '',
      senderUid: data['senderUid'] as String? ?? '',
      senderName: data['senderName'] as String? ?? 'Unknown',
      createdAt: timestamp?.toDate(),
      hasPendingWrites: doc.metadata.hasPendingWrites,
    );
  }
}
