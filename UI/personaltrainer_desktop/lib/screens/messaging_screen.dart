import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personaltrainer_desktop/providers/messages_provider.dart';
import 'package:personaltrainer_desktop/providers/signalr_provider.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart';
import 'package:personaltrainer_desktop/layouts/navBar.dart';

String _formatTimestamp(DateTime? dt) {
  if (dt == null) return '';
  final d = dt.toLocal();
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  final year = d.year.toString();
  final hour = d.hour.toString().padLeft(2, '0');
  final minute = d.minute.toString().padLeft(2, '0');
  return '$day.$month.$year $hour:$minute';
}

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Connect to PresenceHub to get online users
      final presenceProvider = Provider.of<SignalRProvider>(
        context,
        listen: false,
      );
      if (!presenceProvider.isConnected) {
        presenceProvider.connect();
      }

      // Sync online users to messages provider
      final messagesProvider = Provider.of<MessagesProvider>(
        context,
        listen: false,
      );
      messagesProvider.setOnlineUsers(presenceProvider.onlineUsers);
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

    final provider = Provider.of<MessagesProvider>(context, listen: false);
    provider.sendMessage(message);

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthProvider.userId?.toString();

    return NavBar(
      'Messaging',
      Column(
        children: [
          // Connection status bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Consumer<MessagesProvider>(
                  builder: (context, provider, child) {
                    return Row(
                      children: [
                        Icon(
                          provider.isConnected
                              ? Icons.cloud_done
                              : Icons.cloud_off,
                          color: provider.isConnected
                              ? Colors.green
                              : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.isConnected ? 'Connected' : 'Select user',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // User list sidebar
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300),
                    ),
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
                        child: Consumer2<SignalRProvider, MessagesProvider>(
                          builder:
                              (
                                context,
                                presenceProvider,
                                messagesProvider,
                                child,
                              ) {
                                // Sync online users
                                if (presenceProvider.onlineUsers.isNotEmpty) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    messagesProvider.setOnlineUsers(
                                      presenceProvider.onlineUsers,
                                    );
                                  });
                                }

                                final users = presenceProvider.onlineUsers
                                    .where(
                                      (user) => user.userId != currentUserId,
                                    )
                                    .toList();

                                if (users.isEmpty) {
                                  return const Center(
                                    child: Text('No users online'),
                                  );
                                }

                                return ListView.builder(
                                  itemCount: users.length,
                                  itemBuilder: (context, index) {
                                    final user = users[index];
                                    final isSelected =
                                        messagesProvider.currentRecipientId ==
                                        user.userId;

                                    return ListTile(
                                      selected: isSelected,
                                      selectedTileColor: Colors.blue.shade100,
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        child: Text(
                                          user.firstName
                                                  ?.substring(0, 1)
                                                  .toUpperCase() ??
                                              user.email
                                                  ?.substring(0, 1)
                                                  .toUpperCase() ??
                                              'U',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        user.firstName ??
                                            user.email ??
                                            'User ${user.userId}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        'ID: ${user.userId}',
                                        style: const TextStyle(fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () async {
                                        await messagesProvider.connect(
                                          user.userId,
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                        ),
                      ),
                    ],
                  ),
                ),
                // Chat area
                Expanded(
                  child: Column(
                    children: [
                      // Current chat header
                      Consumer<MessagesProvider>(
                        builder: (context, provider, child) {
                          if (provider.currentRecipientId == null) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              color: Colors.grey.shade100,
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline),
                                  SizedBox(width: 8),
                                  Text('Select a user to start messaging'),
                                ],
                              ),
                            );
                          }

                          final recipient = provider.onlineUsers
                              .where(
                                (u) => u.userId == provider.currentRecipientId,
                              )
                              .firstOrNull;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.blue.shade50,
                            child: Row(
                              children: [
                                const Icon(Icons.chat, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Chat with ${recipient?.firstName ?? recipient?.email ?? "User ${provider.currentRecipientId}"}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // Messages list
                      Expanded(
                        child: Consumer<MessagesProvider>(
                          builder: (context, provider, child) {
                            if (provider.currentRecipientId == null) {
                              return const Center(
                                child: Text(
                                  'Select a user from the list to start chatting',
                                ),
                              );
                            }

                            if (provider.messages.isEmpty) {
                              return const Center(
                                child: Text('No messages yet'),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.messages.length,
                              itemBuilder: (context, index) {
                                final message = provider.messages[index];
                                final isSentByMe =
                                    message.userId == currentUserId;

                                return Align(
                                  alignment: isSentByMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSentByMe
                                          ? Colors.blue.shade100
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                          0.6,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.message ?? '',
                                          style: const TextStyle(fontSize: 14),
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
                      Consumer<MessagesProvider>(
                        builder: (context, provider, child) {
                          final canSend =
                              provider.isConnected &&
                              provider.currentRecipientId != null;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    enabled: canSend,
                                    decoration: InputDecoration(
                                      hintText: canSend
                                          ? 'Enter your message'
                                          : 'Select a user to start messaging',
                                    ),
                                    onSubmitted: canSend
                                        ? (_) => _sendMessage()
                                        : null,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: canSend ? _sendMessage : null,
                                ),
                              ],
                            ),
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
}
