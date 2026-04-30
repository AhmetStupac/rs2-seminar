import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:personaltrainer_mobile/models/notification.dart';
import 'package:personaltrainer_mobile/providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetch();
      _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetch());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _fetch() {
    if (!mounted) return;
    Provider.of<NotificationProvider>(
      context,
      listen: false,
    ).loadNotifications(page: 1, pageSize: 50);
  }

  Future<void> _refresh() async {
    await Provider.of<NotificationProvider>(
      context,
      listen: false,
    ).loadNotifications(page: 1, pageSize: 50);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications),
                    if (provider.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            provider.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<NotificationProvider>(
                context,
                listen: false,
              ).markAllRead();
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.notifications.isEmpty) {
            return Center(
              child: Text(provider.error ?? 'Failed to load notifications.'),
            );
          }

          if (provider.notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No notifications yet.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: provider.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _NotificationCard(
                  notification: notification,
                  onTap: () async {
                    if (notification.id != null && !notification.isRead) {
                      await Provider.of<NotificationProvider>(
                        context,
                        listen: false,
                      ).markRead(notification.id!);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final createdAt = notification.createdAt;
    final formattedDate = createdAt != null
        ? DateFormat('dd.MM.yyyy HH:mm').format(createdAt)
        : 'Unknown time';

    return Card(
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead ? Colors.white : Colors.orange.shade50,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          notification.isRead ? Icons.mark_email_read : Icons.mark_email_unread,
          color: notification.isRead ? Colors.grey : Colors.orange.shade700,
        ),
        title: Text(
          notification.title ?? 'Notification',
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message ?? ''),
            const SizedBox(height: 6),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: notification.type != null && notification.type!.isNotEmpty
            ? Chip(
                label: Text(notification.type!),
                backgroundColor: Colors.orange.shade100,
              )
            : null,
      ),
    );
  }
}
