import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personaltrainer_mobile/providers/signalr_provider.dart';
import 'package:personaltrainer_mobile/models/message.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({Key? key}) : super(key: key);

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedUserId;
  bool _isPrivateMode = false;
  bool _useHttpEndpoint = false; // Toggle between SignalR and HTTP

  @override
  void initState() {
    super.initState();
    // Connect when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SignalRProvider>(context, listen: false);
      if (!provider.isConnected) {
        provider.connect();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final provider = Provider.of<SignalRProvider>(context, listen: false);

    if (_isPrivateMode && _selectedUserId != null) {
      // Private messages only work via SignalR
      provider.sendPrivateMessage(_selectedUserId!, message);
    } else {
      // Public messages can use either SignalR or HTTP
      if (_useHttpEndpoint) {
        provider.sendMessageViaHttp(message);
      } else {
        provider.sendMessage(message);
      }
    }

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messaging'),
        actions: [
          Consumer<SignalRProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  Icon(
                    provider.isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: provider.isConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.isConnected ? 'Connected' : 'Disconnected',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  // HTTP/SignalR toggle for broadcast messages
                  if (!_isPrivateMode)
                    Row(
                      children: [
                        const Icon(Icons.api, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _useHttpEndpoint ? 'HTTP' : 'SignalR',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Switch(
                          value: _useHttpEndpoint,
                          onChanged: (value) {
                            setState(() {
                              _useHttpEndpoint = value;
                            });
                          },
                        ),
                      ],
                    ),
                  const SizedBox(width: 8),
                ],
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Online Users Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: const Row(
                    children: [
                      Icon(Icons.people, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Online Users',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<SignalRProvider>(
                    builder: (context, provider, child) {
                      if (provider.onlineUsers.isEmpty) {
                        return const Center(child: Text('No users online'));
                      }

                      return ListView.builder(
                        itemCount: provider.onlineUsers.length,
                        itemBuilder: (context, index) {
                          final user = provider.onlineUsers[index];
                          final isSelected = _selectedUserId == user.userId;
                          final isCurrentUser =
                              user.userId == AuthProvider.userId?.toString();

                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: Colors.blue.shade100,
                            leading: CircleAvatar(
                              backgroundColor: isCurrentUser
                                  ? Colors.green
                                  : Colors.blue,
                              child: Text(
                                user.email?.substring(0, 1).toUpperCase() ??
                                    'U',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              user.email ?? user.userId,
                              style: TextStyle(
                                fontWeight: isCurrentUser
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              isCurrentUser
                                  ? '(You)'
                                  : 'User ID: ${user.userId}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: isCurrentUser
                                ? null
                                : IconButton(
                                    icon: Icon(
                                      _isPrivateMode && isSelected
                                          ? Icons.message
                                          : Icons.message_outlined,
                                      color: _isPrivateMode && isSelected
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedUserId = user.userId;
                                        _isPrivateMode = true;
                                      });
                                    },
                                    tooltip: 'Send private message',
                                  ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Chat Area
          Expanded(
            child: Column(
              children: [
                // Mode indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  color: _isPrivateMode
                      ? Colors.purple.shade50
                      : Colors.blue.shade50,
                  child: Row(
                    children: [
                      Icon(
                        _isPrivateMode ? Icons.lock : Icons.public,
                        color: _isPrivateMode ? Colors.purple : Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isPrivateMode
                              ? 'Private chat with User ${_selectedUserId ?? "unknown"}'
                              : 'Public chat (all users)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (_isPrivateMode)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _isPrivateMode = false;
                              _selectedUserId = null;
                            });
                          },
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Exit private chat'),
                        ),
                    ],
                  ),
                ),

                // Error display
                Consumer<SignalRProvider>(
                  builder: (context, provider, child) {
                    if (provider.error != null) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.red.shade100,
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                provider.error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () => provider.clearError(),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Messages list
                Expanded(
                  child: Consumer<SignalRProvider>(
                    builder: (context, provider, child) {
                      if (provider.messages.isEmpty) {
                        return const Center(child: Text('No messages yet'));
                      }

                      // Filter messages based on mode
                      final messages = _isPrivateMode
                          ? provider.messages.where((m) {
                              return m.isPrivate &&
                                  (m.fromUserId == _selectedUserId ||
                                      m.toUserId == _selectedUserId);
                            }).toList()
                          : provider.messages
                                .where((m) => !m.isPrivate)
                                .toList();

                      if (messages.isEmpty && _isPrivateMode) {
                        return const Center(
                          child: Text('No private messages yet'),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isOwnMessage =
                              (message.userId ?? message.fromUserId) ==
                              AuthProvider.userId?.toString();

                          return Align(
                            alignment: isOwnMessage
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              constraints: const BoxConstraints(maxWidth: 500),
                              decoration: BoxDecoration(
                                color: isOwnMessage
                                    ? Colors.blue.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        message.isPrivate
                                            ? Icons.lock
                                            : Icons.public,
                                        size: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        message.user ??
                                            message.from ??
                                            message.email ??
                                            'Unknown',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    message.message ?? '',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTimestamp(message.timestamp),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Message input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: _isPrivateMode
                                ? 'Send a private message...'
                                : 'Send a message to everyone...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Consumer<SignalRProvider>(
                        builder: (context, provider, child) {
                          return FloatingActionButton(
                            onPressed: provider.isConnected
                                ? _sendMessage
                                : null,
                            backgroundColor: provider.isConnected
                                ? Colors.blue
                                : Colors.grey,
                            child: const Icon(Icons.send),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
