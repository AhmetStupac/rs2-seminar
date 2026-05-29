import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personaltrainer_mobile/providers/messages_provider.dart';
import 'package:personaltrainer_mobile/models/message.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
import 'package:personaltrainer_mobile/utils/message_content.dart';

class ChatScreen extends StatefulWidget {
  final OnlineUser selectedUser;

  const ChatScreen({super.key, required this.selectedUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _connectToUser();
  }

  Future<void> _connectToUser() async {
    final messagesProvider = Provider.of<MessagesProvider>(
      context,
      listen: false,
    );
    await messagesProvider.connect(widget.selectedUser.userId);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final raw = _messageController.text;
    final validationError = MessageContent.validateForSend(raw);
    if (validationError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationError)),
        );
      }
      return;
    }

    final messagesProvider = Provider.of<MessagesProvider>(
      context,
      listen: false,
    );
    final content = MessageContent.prepareForSend(raw);

    _messageController.clear();
    final sent = await messagesProvider.sendMessage(content);
    if (!mounted) return;

    if (!sent && messagesProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(messagesProvider.error!)),
      );
    } else {
      _scrollToBottom();
    }
  }

  Widget _buildMessagesList(MessagesProvider messagesProvider) {
    final currentUserId = AuthProvider.userId?.toString();

    if (messagesProvider.messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No messages',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start a conversation!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messagesProvider.messages.length,
      itemBuilder: (context, index) {
        final message = messagesProvider.messages[index];
        final isMe =
            message.fromUserId == currentUserId ||
            message.userId == currentUserId;

        return _buildMessageBubble(message, isMe);
      },
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.orange.shade300 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              MessageContent.forDisplay(message.message),
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes';
    } else if (difference.inDays < 1) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}.${timestamp.month}. ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildMessageInput(MessagesProvider messagesProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLength: MessageContent.maxLength,
              maxLines: 4,
              minLines: 1,
              decoration: const InputDecoration(
                hintText: 'Write a message...',
                border: InputBorder.none,
                counterText: '',
              ),
              enabled: messagesProvider.isConnected,
              onSubmitted: (_) => _sendMessage(),
              onChanged: (_) => setState(() {}),
            ),
          ),
          IconButton(
            icon: CircleAvatar(
              backgroundColor:
                  messagesProvider.isConnected &&
                      _messageController.text.isNotEmpty
                  ? Colors.orange
                  : Colors.grey,
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
            onPressed:
                messagesProvider.isConnected &&
                    _messageController.text.isNotEmpty
                ? _sendMessage
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Consumer<MessagesProvider>(
      builder: (context, messagesProvider, _) {
        if (!messagesProvider.isConnected) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Connecting...'),
              ],
            ),
          );
        }

        if (messagesProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${messagesProvider.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      messagesProvider.connect(widget.selectedUser.userId),
                  child: const Text('Try again'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Chat header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Text(
                      widget.selectedUser.firstName
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          widget.selectedUser.email
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          widget.selectedUser.userId
                              .substring(0, 1)
                              .toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.selectedUser.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              'Online',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      messagesProvider.disconnect();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            // Messages list
            Expanded(child: _buildMessagesList(messagesProvider)),
            // Message input
            _buildMessageInput(messagesProvider),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedUser.displayName),
        backgroundColor: Colors.orange.shade400,
        foregroundColor: Colors.white,
      ),
      body: _buildChatArea(),
    );
  }
}
