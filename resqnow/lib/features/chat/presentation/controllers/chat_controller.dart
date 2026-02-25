import 'package:flutter/material.dart';
import 'package:resqnow/features/chat/data/models/index.dart';
import 'package:resqnow/features/chat/data/services/chat_service.dart';

class ChatController extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  ChatRoom? _currentChatRoom;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  ChatRoom? get currentChatRoom => _currentChatRoom;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get or create a chat room and load it
  Future<void> getChatRoom({
    required String otherUserId,
    required String otherUserName,
    required String otherUserBloodGroup,
    String? otherUserImageUrl,
    required String currentUserName,
    required String currentUserBloodGroup,
    String? currentUserImageUrl,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentChatRoom = await _chatService.getOrCreateChatRoom(
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserBloodGroup: otherUserBloodGroup,
        otherUserImageUrl: otherUserImageUrl,
        currentUserName: currentUserName,
        currentUserBloodGroup: currentUserBloodGroup,
        currentUserImageUrl: currentUserImageUrl,
      );

      // Load initial messages
      await _loadMessages();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading chat: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load messages from stream
  Future<void> _loadMessages() async {
    if (_currentChatRoom == null) return;

    try {
      final messagesStream = _chatService.getMessagesStream(
        _currentChatRoom!.id,
      );
      // Take the first emission to get initial messages
      final messages = await messagesStream.first;
      _messages = messages;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading messages: $e';
      notifyListeners();
    }
  }

  /// Send a message
  Future<void> sendMessage({
    required String messageText,
    required String senderName,
    required String senderBloodGroup,
    String? senderImageUrl,
  }) async {
    if (_currentChatRoom == null) {
      _errorMessage = 'Chat room not initialized';
      notifyListeners();
      return;
    }

    try {
      await _chatService.sendMessage(
        chatRoomId: _currentChatRoom!.id,
        messageText: messageText,
        senderName: senderName,
        senderBloodGroup: senderBloodGroup,
        senderImageUrl: senderImageUrl,
      );

      // Reload messages after sending
      await _loadMessages();
    } catch (e) {
      _errorMessage = 'Error sending message: $e';
      notifyListeners();
    }
  }

  /// Get messages stream
  Stream<List<Message>> getMessagesStream() {
    if (_currentChatRoom == null) {
      return Stream.value([]);
    }
    return _chatService.getMessagesStream(_currentChatRoom!.id);
  }

  /// Get chat room stream for metadata updates
  Stream<ChatRoom?> getChatRoomStream() {
    if (_currentChatRoom == null) {
      return Stream.value(null);
    }
    return _chatService.getChatRoomStream(_currentChatRoom!.id);
  }

  /// Delete chat room
  Future<void> deleteChatRoom() async {
    if (_currentChatRoom == null) return;

    try {
      await _chatService.deleteChatRoom(_currentChatRoom!.id);
      _currentChatRoom = null;
      _messages = [];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting chat: $e';
      notifyListeners();
    }
  }

  /// Clear chat history
  Future<void> clearChatHistory() async {
    if (_currentChatRoom == null) return;

    try {
      await _chatService.clearChatHistory(_currentChatRoom!.id);
      _messages = [];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error clearing history: $e';
      notifyListeners();
    }
  }

}
