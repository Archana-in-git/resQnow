import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resqnow/features/chat/data/models/index.dart';

/// ChatService handles all Firestore operations for private messaging
///
/// Firestore Structure:
/// ```
/// chats/
///   ├── {chatRoomId}/
///   │   ├── metadata (document with room info)
///   │   └── messages/ (subcollection)
///   │       └── {messageId} (message documents)
/// ```
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _chatsCollection = 'chats';
  static const String _messagesCollection = 'messages';
  static const String _metadataDoc = 'metadata';

  /// Get current user ID
  String get _currentUserId => _auth.currentUser?.uid ?? '';

  /// Generate a unique chat room ID (sorted participant IDs for consistency)
  String _generateChatRoomId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Get or create a chat room between current user and another user
  Future<ChatRoom> getOrCreateChatRoom({
    required String otherUserId,
    required String otherUserName,
    required String otherUserBloodGroup,
    String? otherUserImageUrl,
    required String currentUserName,
    required String currentUserBloodGroup,
    String? currentUserImageUrl,
  }) async {
    try {
      final chatRoomId = _generateChatRoomId(_currentUserId, otherUserId);
      final chatRoomRef = _firestore
          .collection(_chatsCollection)
          .doc(chatRoomId);

      // Check if chat room exists
      final docSnapshot = await chatRoomRef.get();

      if (docSnapshot.exists) {
        // Chat room already exists, return it
        return ChatRoom.fromSnapshot(docSnapshot);
      } else {
        // Create new chat room
        final now = DateTime.now();
        final newChatRoom = ChatRoom(
          id: chatRoomId,
          participant1Id: _currentUserId,
          participant2Id: otherUserId,
          participant1Name: currentUserName,
          participant2Name: otherUserName,
          participant1BloodGroup: currentUserBloodGroup,
          participant2BloodGroup: otherUserBloodGroup,
          participant1ImageUrl: currentUserImageUrl,
          participant2ImageUrl: otherUserImageUrl,
          lastMessage: '',
          lastMessageTime: now,
          createdAt: now,
          unreadCount: 0,
        );

        await chatRoomRef.set(newChatRoom.toMap());
        return newChatRoom;
      }
    } catch (e) {
      throw Exception('Error getting/creating chat room: $e');
    }
  }

  /// Send a message to a chat room
  Future<void> sendMessage({
    required String chatRoomId,
    required String messageText,
    required String senderName,
    required String senderBloodGroup,
    String? senderImageUrl,
  }) async {
    try {
      final now = DateTime.now();
      final messageId = _firestore
          .collection(_chatsCollection)
          .doc(chatRoomId)
          .collection(_messagesCollection)
          .doc()
          .id;

      // Create message
      final message = Message(
        id: messageId,
        senderId: _currentUserId,
        senderName: senderName,
        senderBloodGroup: senderBloodGroup,
        senderImageUrl: senderImageUrl,
        text: messageText,
        timestamp: now,
        isRead: false,
      );

      // Add message to subcollection
      await _firestore
          .collection(_chatsCollection)
          .doc(chatRoomId)
          .collection(_messagesCollection)
          .doc(messageId)
          .set(message.toMap());

      // Update chat room's last message
      await _firestore.collection(_chatsCollection).doc(chatRoomId).update({
        'lastMessage': messageText,
        'lastMessageTime': now.millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  /// Get messages stream for a chat room (ordered by timestamp, newest first)
  Stream<List<Message>> getMessagesStream(String chatRoomId) {
    try {
      return _firestore
          .collection(_chatsCollection)
          .doc(chatRoomId)
          .collection(_messagesCollection)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Message.fromSnapshot(doc))
                .toList();
          });
    } catch (e) {
      throw Exception('Error getting messages stream: $e');
    }
  }

  /// Get single chat room by ID
  Future<ChatRoom?> getChatRoom(String chatRoomId) async {
    try {
      final doc = await _firestore
          .collection(_chatsCollection)
          .doc(chatRoomId)
          .get();

      if (doc.exists) {
        return ChatRoom.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting chat room: $e');
    }
  }

  /// Get chat room stream for real-time updates
  Stream<ChatRoom?> getChatRoomStream(String chatRoomId) {
    try {
      return _firestore
          .collection(_chatsCollection)
          .doc(chatRoomId)
          .snapshots()
          .map((snapshot) {
            if (snapshot.exists) {
              return ChatRoom.fromSnapshot(snapshot);
            }
            return null;
          });
    } catch (e) {
      throw Exception('Error getting chat room stream: $e');
    }
  }

  /// Get all chat rooms for current user
  Future<List<ChatRoom>> getUserChatRooms() async {
    try {
      final query1 = await _firestore
          .collection(_chatsCollection)
          .where('participant1Id', isEqualTo: _currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      final query2 = await _firestore
          .collection(_chatsCollection)
          .where('participant2Id', isEqualTo: _currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      final chatRooms1 = query1.docs
          .map((doc) => ChatRoom.fromSnapshot(doc))
          .toList();
      final chatRooms2 = query2.docs
          .map((doc) => ChatRoom.fromSnapshot(doc))
          .toList();

      final allChats = [...chatRooms1, ...chatRooms2];
      allChats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

      return allChats;
    } catch (e) {
      throw Exception('Error getting user chat rooms: $e');
    }
  }

  /// Get user chat rooms as stream
  Stream<List<ChatRoom>> getUserChatRoomsStream() {
    try {
      return _firestore
          .collection(_chatsCollection)
          .where('participant1Id', isEqualTo: _currentUserId)
          .snapshots()
          .asyncMap((query1) async {
            final query2 = await _firestore
                .collection(_chatsCollection)
                .where('participant2Id', isEqualTo: _currentUserId)
                .get();

            final chatRooms1 = query1.docs
                .map((doc) => ChatRoom.fromSnapshot(doc))
                .toList();
            final chatRooms2 = query2.docs
                .map((doc) => ChatRoom.fromSnapshot(doc))
                .toList();

            final allChats = [...chatRooms1, ...chatRooms2];
            allChats.sort(
              (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
            );

            return allChats;
          });
    } catch (e) {
      throw Exception('Error getting user chat rooms stream: $e');
    }
  }

  /// Delete a chat room and all its messages
  Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      // Delete all messages
      final messagesRef = _firestore
          .collection(_chatsCollection)
          .doc(chatRoomId)
          .collection(_messagesCollection);

      final snapshot = await messagesRef.get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Delete chat room
      await _firestore.collection(_chatsCollection).doc(chatRoomId).delete();
    } catch (e) {
      throw Exception('Error deleting chat room: $e');
    }
  }

  /// Clear all messages in a chat (keep room metadata)
  Future<void> clearChatHistory(String chatRoomId) async {
    try {
      final messagesRef = _firestore
          .collection(_chatsCollection)
          .doc(chatRoomId)
          .collection(_messagesCollection);

      final snapshot = await messagesRef.get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Reset last message
      await _firestore.collection(_chatsCollection).doc(chatRoomId).update({
        'lastMessage': '',
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Error clearing chat history: $e');
    }
  }

  // ================== FIRESTORE SCHEMA DOCUMENTATION ==================
  ///
  /// Firestore Structure:
  ///
  /// Collection: chats
  /// ├── Document: {participant1Id}_{participant2Id} (sorted alphabetically)
  /// │   ├── participant1Id (string)
  /// │   ├── participant2Id (string)
  /// │   ├── participant1Name (string)
  /// │   ├── participant2Name (string)
  /// │   ├── participant1BloodGroup (string)
  /// │   ├── participant2BloodGroup (string)
  /// │   ├── participant1ImageUrl (string, optional)
  /// │   ├── participant2ImageUrl (string, optional)
  /// │   ├── lastMessage (string)
  /// │   ├── lastMessageTime (timestamp)
  /// │   ├── createdAt (timestamp)
  /// │   ├── unreadCount (number)
  /// │   └── messages/ (subcollection)
  /// │       └── Document: {messageId}
  /// │           ├── id (string)
  /// │           ├── senderId (string)
  /// │           ├── senderName (string)
  /// │           ├── senderBloodGroup (string)
  /// │           ├── senderImageUrl (string, optional)
  /// │           ├── text (string)
  /// │           ├── timestamp (timestamp)
  /// │           └── isRead (boolean)
  ///
  /// Privacy Considerations:
  /// - Phone numbers are NOT stored in messages or chat rooms
  /// - Emails are NOT stored in messages or chat rooms
  /// - Only first name or anonymous label is shown
  /// - Blood group is displayed for context
  /// - Profile images are optional and can be masked
  ///
  /// Firestore Security Rules (recommended):
  /// ```
  /// rules_version = '2';
  /// service cloud.firestore {
  ///   match /databases/{database}/documents {
  ///     match /chats/{chatId} {
  ///       allow read, write: if request.auth.uid in [resource.data.participant1Id, resource.data.participant2Id];
  ///       match /messages/{messageId} {
  ///         allow read, write: if request.auth.uid in [resource.data.senderId] ||
  ///                              request.auth.uid in [get(/databases/$(database)/documents/chats/$(chatId)).data.participant1Id,
  ///                                                     get(/databases/$(database)/documents/chats/$(chatId)).data.participant2Id];
  ///       }
  ///     }
  ///   }
  /// }
  /// ```
}
