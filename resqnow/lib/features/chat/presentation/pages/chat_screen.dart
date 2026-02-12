import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/features/chat/presentation/controllers/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String otherUserBloodGroup;
  final String? otherUserImageUrl;
  final String currentUserName;
  final String currentUserBloodGroup;
  final String? currentUserImageUrl;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserBloodGroup,
    this.otherUserImageUrl,
    required this.currentUserName,
    required this.currentUserBloodGroup,
    this.currentUserImageUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _chatInitialized = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.grey.shade800 : AppColors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildAppBarTitle(isDarkMode),
        centerTitle: false,
      ),
      body: Consumer<ChatController>(
        builder: (context, chatController, _) {
          // Initialize chat on first build
          if (!_chatInitialized) {
            _chatInitialized = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              chatController.getChatRoom(
                otherUserId: widget.otherUserId,
                otherUserName: widget.otherUserName,
                otherUserBloodGroup: widget.otherUserBloodGroup,
                otherUserImageUrl: widget.otherUserImageUrl,
                currentUserName: widget.currentUserName,
                currentUserBloodGroup: widget.currentUserBloodGroup,
                currentUserImageUrl: widget.currentUserImageUrl,
              );
            });
          }

          if (chatController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chatController.currentChatRoom == null) {
            return Center(
              child: Text(
                'Error loading chat',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey,
                ),
              ),
            );
          }

          return _buildChatUI(isDarkMode, chatController);
        },
      ),
    );
  }

  Widget _buildAppBarTitle(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.otherUserName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.otherUserBloodGroup,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.verified_rounded, size: 14, color: Colors.blue.shade500),
          ],
        ),
      ],
    );
  }

  Widget _buildChatUI(bool isDarkMode, ChatController chatController) {
    return DashChat(
      messageOptions: MessageOptions(
        currentUserContainerColor: AppColors.primary,
        currentUserTextColor: Colors.white,
        containerColor: isDarkMode
            ? Colors.grey.shade800
            : Colors.grey.shade200,
        textColor: isDarkMode ? Colors.white : AppColors.textPrimary,
        messageTextBuilder: (message, previous, next) {
          return Text(
            message.text,
            style: TextStyle(
              fontSize: 14,
              color: message.user.id == widget.currentUserName
                  ? Colors.white
                  : (isDarkMode ? Colors.white : AppColors.textPrimary),
            ),
          );
        },
        messagePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: 16,
        showTime: true,
      ),
      currentUser: ChatUser(
        id: widget.currentUserName,
        firstName: widget.currentUserName,
        profileImage: widget.currentUserImageUrl,
      ),
      onSend: (ChatMessage message) async {
        _sendMessage(message, chatController);
        // Force a rebuild to show new message
        setState(() {});
      },
      messages: _buildMessageList(chatController),
      inputOptions: InputOptions(
        cursorStyle: CursorStyle(color: AppColors.primary),
        textCapitalization: TextCapitalization.sentences,
        inputDecoration: InputDecoration(
          hintText: 'Type a message...',
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.grey.shade500 : Colors.grey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        leading: [
          GestureDetector(
            onTap: () {
              _showChatOptions(context);
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.more_vert_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ChatMessage> _buildMessageList(ChatController chatController) {
    final messages = chatController.messages;
    return messages
        .map(
          (msg) => ChatMessage(
            text: msg.text,
            user: ChatUser(id: msg.senderId, firstName: msg.senderName),
            createdAt: msg.timestamp,
          ),
        )
        .toList()
        .reversed
        .toList();
  }

  void _sendMessage(ChatMessage message, ChatController chatController) {
    chatController.sendMessage(
      messageText: message.text,
      senderName: widget.currentUserName,
      senderBloodGroup: widget.currentUserBloodGroup,
      senderImageUrl: widget.currentUserImageUrl,
    );
    _messageController.clear();
  }

  void _showChatOptions(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildOption(
                icon: Icons.delete_rounded,
                label: 'Clear Chat History',
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.pop(context);
                  _showClearHistoryConfirmation(context);
                },
              ),
              _buildOption(
                icon: Icons.block_rounded,
                label: 'Delete Chat',
                isDarkMode: isDarkMode,
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteChatConfirmation(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required bool isDarkMode,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? Colors.red
                    : (isDarkMode ? Colors.white : AppColors.textPrimary),
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDestructive
                      ? Colors.red
                      : (isDarkMode ? Colors.white : AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearHistoryConfirmation(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
        title: Text(
          'Clear Chat History',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all messages? This action cannot be undone.',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatController>().clearChatHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showDeleteChatConfirmation(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
        title: Text(
          'Delete Chat',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this entire conversation? This action cannot be undone.',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatController>().deleteChatRoom();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
