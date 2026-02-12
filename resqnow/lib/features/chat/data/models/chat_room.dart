import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final String participant1Id; // User who initiated
  final String participant2Id; // Donor/Receiver
  final String participant1Name;
  final String participant2Name;
  final String participant1BloodGroup;
  final String participant2BloodGroup;
  final String? participant1ImageUrl;
  final String? participant2ImageUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final DateTime createdAt;
  final int unreadCount;

  ChatRoom({
    required this.id,
    required this.participant1Id,
    required this.participant2Id,
    required this.participant1Name,
    required this.participant2Name,
    required this.participant1BloodGroup,
    required this.participant2BloodGroup,
    this.participant1ImageUrl,
    this.participant2ImageUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,
    this.unreadCount = 0,
  });

  /// Convert ChatRoom to JSON (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'participant1Id': participant1Id,
      'participant2Id': participant2Id,
      'participant1Name': participant1Name,
      'participant2Name': participant2Name,
      'participant1BloodGroup': participant1BloodGroup,
      'participant2BloodGroup': participant2BloodGroup,
      'participant1ImageUrl': participant1ImageUrl,
      'participant2ImageUrl': participant2ImageUrl,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'unreadCount': unreadCount,
    };
  }

  /// Create ChatRoom from Firestore document
  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      participant1Id: map['participant1Id'] as String? ?? '',
      participant2Id: map['participant2Id'] as String? ?? '',
      participant1Name: map['participant1Name'] as String? ?? 'User 1',
      participant2Name: map['participant2Name'] as String? ?? 'User 2',
      participant1BloodGroup:
          map['participant1BloodGroup'] as String? ?? 'Unknown',
      participant2BloodGroup:
          map['participant2BloodGroup'] as String? ?? 'Unknown',
      participant1ImageUrl: map['participant1ImageUrl'] as String?,
      participant2ImageUrl: map['participant2ImageUrl'] as String?,
      lastMessage: map['lastMessage'] as String? ?? '',
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'] as int)
          : DateTime.now(),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
      unreadCount: map['unreadCount'] as int? ?? 0,
    );
  }

  /// Create ChatRoom from Firestore DocumentSnapshot
  factory ChatRoom.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    return ChatRoom.fromMap(data, snapshot.id);
  }

  /// Create a copy with modified fields
  ChatRoom copyWith({
    String? id,
    String? participant1Id,
    String? participant2Id,
    String? participant1Name,
    String? participant2Name,
    String? participant1BloodGroup,
    String? participant2BloodGroup,
    String? participant1ImageUrl,
    String? participant2ImageUrl,
    String? lastMessage,
    DateTime? lastMessageTime,
    DateTime? createdAt,
    int? unreadCount,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participant1Id: participant1Id ?? this.participant1Id,
      participant2Id: participant2Id ?? this.participant2Id,
      participant1Name: participant1Name ?? this.participant1Name,
      participant2Name: participant2Name ?? this.participant2Name,
      participant1BloodGroup:
          participant1BloodGroup ?? this.participant1BloodGroup,
      participant2BloodGroup:
          participant2BloodGroup ?? this.participant2BloodGroup,
      participant1ImageUrl: participant1ImageUrl ?? this.participant1ImageUrl,
      participant2ImageUrl: participant2ImageUrl ?? this.participant2ImageUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdAt: createdAt ?? this.createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  String toString() =>
      'ChatRoom(id: $id, participant1: $participant1Name, participant2: $participant2Name)';
}
