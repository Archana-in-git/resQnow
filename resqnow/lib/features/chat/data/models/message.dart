import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String senderBloodGroup;
  final String? senderImageUrl;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderBloodGroup,
    this.senderImageUrl,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  /// Convert Message to JSON (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderBloodGroup': senderBloodGroup,
      'senderImageUrl': senderImageUrl,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  /// Create Message from Firestore document
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? 'Anonymous',
      senderBloodGroup: map['senderBloodGroup'] as String? ?? 'Unknown',
      senderImageUrl: map['senderImageUrl'] as String?,
      text: map['text'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  /// Create Message from Firestore DocumentSnapshot
  factory Message.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    return Message.fromMap({...data, 'id': snapshot.id});
  }

  /// Create a copy with modified fields
  Message copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderBloodGroup,
    String? senderImageUrl,
    String? text,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderBloodGroup: senderBloodGroup ?? this.senderBloodGroup,
      senderImageUrl: senderImageUrl ?? this.senderImageUrl,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  String toString() => 'Message(id: $id, senderId: $senderId, text: $text)';
}
