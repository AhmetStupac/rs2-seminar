import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personaltrainer_mobile/providers/signalr_provider.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
import 'package:personaltrainer_mobile/layouts/mobile_navbar.dart';
import 'package:personaltrainer_mobile/screens/chat_screen.dart';

class OnlineUsersScreen extends StatefulWidget {
  const OnlineUsersScreen({super.key});

  @override
  State<OnlineUsersScreen> createState() => _OnlineUsersScreenState();
}

class _OnlineUsersScreenState extends State<OnlineUsersScreen> {
  @override
  void initState() {
    super.initState();
    _initializeSignalR();
  }

  Future<void> _initializeSignalR() async {
    final signalRProvider = Provider.of<SignalRProvider>(
      context,
      listen: false,
    );

    if (!signalRProvider.isConnected) {
      await signalRProvider.connect();
    }

    // Refresh online users list
    await Future.delayed(const Duration(milliseconds: 500));
    await signalRProvider.refreshOnlineUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Users'),
        backgroundColor: Colors.orange.shade400,
        foregroundColor: Colors.white,
        actions: [
          Consumer<SignalRProvider>(
            builder: (context, signalRProvider, _) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh online users',
                    onPressed: signalRProvider.isConnected
                        ? () async {
                            await signalRProvider.refreshOnlineUsers();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Online users: ${signalRProvider.onlineUsers.length}',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          }
                        : null,
                  ),
                  IconButton(
                    icon: Icon(
                      signalRProvider.isConnected
                          ? Icons.cloud_done
                          : Icons.cloud_off,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            signalRProvider.isConnected
                                ? 'Connected'
                                : 'Disconnected',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: const MobileNavBar(currentRoute: 'chat'),
      body: Consumer<SignalRProvider>(
        builder: (context, signalRProvider, _) {
          if (!signalRProvider.isConnected) {
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

          final currentUserId = AuthProvider.userId?.toString();
          final otherUsers = signalRProvider.onlineUsers
              .where((user) => user.userId != currentUserId)
              .toList();

          if (otherUsers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No available users',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No one is online',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await signalRProvider.refreshOnlineUsers();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: otherUsers.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final user = otherUsers[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 28,
                    child: Text(
                      user.firstName?.substring(0, 1).toUpperCase() ??
                          user.email?.substring(0, 1).toUpperCase() ??
                          user.userId.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    user.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Online',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chat_bubble, color: Colors.orange),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(selectedUser: user),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
