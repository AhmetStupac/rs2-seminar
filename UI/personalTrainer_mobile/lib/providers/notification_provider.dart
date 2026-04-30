import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:personaltrainer_mobile/models/notification.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;
  DateTime? _lastCreatedAt;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications({
    bool? isRead,
    DateTime? createdAfter,
    int page = 1,
    int pageSize = 20,
    bool replace = true,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final uri = _buildNotificationsUri(
        isRead: isRead,
        createdAfter: createdAfter,
        page: page,
        pageSize: pageSize,
      );

      final response = await BaseProvider.client.get(
        uri,
        headers: _createHeaders(),
      );

      if (response.statusCode < 300) {
        final items = _parseNotificationsResponse(response.body);
        if (replace) {
          _notifications
            ..clear()
            ..addAll(items);
        } else {
          _mergeNotifications(items);
        }
        _updateLastCreatedAt(items);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        final body = response.body;
        throw Exception('API Error (${response.statusCode}): $body');
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markRead(int id) async {
    try {
      final uri = Uri.parse('${BaseProvider.baseUrl}Notifications/$id/read');
      final response = await BaseProvider.client.post(
        uri,
        headers: _createHeaders(),
      );

      if (response.statusCode < 300) {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          _notifications[index].isRead = true;
          _notifications[index].readAt ??= DateTime.now();
          notifyListeners();
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('API Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    try {
      final uri = Uri.parse('${BaseProvider.baseUrl}Notifications/read-all');
      final response = await BaseProvider.client.post(
        uri,
        headers: _createHeaders(),
      );

      if (response.statusCode < 300) {
        for (final notification in _notifications) {
          notification.isRead = true;
          notification.readAt ??= DateTime.now();
        }
        notifyListeners();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('API Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  void startPolling({Duration interval = const Duration(seconds: 7)}) {
    if (_pollingTimer != null) return;
    _pollingTimer = Timer.periodic(interval, (_) async {
      await loadNotifications(
        createdAfter: _lastCreatedAt,
        page: 1,
        pageSize: 50,
        replace: false,
      );
    });
  }

  void stopPolling({bool clearNotifications = true}) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    if (clearNotifications) {
      _notifications.clear();
      _lastCreatedAt = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopPolling(clearNotifications: false);
    super.dispose();
  }

  Uri _buildNotificationsUri({
    bool? isRead,
    DateTime? createdAfter,
    int page = 1,
    int pageSize = 20,
  }) {
    // Backend pagination is 0-indexed: it skips (Page * PageSize) records.
    // Callers pass 1-indexed pages (page: 1 = first page), so convert here.
    final zeroBasedPage = page > 0 ? page - 1 : 0;
    final params = <String, String>{
      'Page': zeroBasedPage.toString(),
      'PageSize': pageSize.toString(),
    };

    if (isRead != null) {
      params['IsRead'] = isRead.toString();
    }
    if (createdAfter != null) {
      params['CreatedAfter'] = createdAfter.toIso8601String();
    }

    return Uri.parse(
      '${BaseProvider.baseUrl}Notifications',
    ).replace(queryParameters: params.isEmpty ? null : params);
  }

  Map<String, String> _createHeaders() {
    final token = AuthProvider.token ?? '';
    final headers = {'Content-Type': 'application/json'};
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  List<NotificationItem> _parseNotificationsResponse(String body) {
    final data = jsonDecode(body);
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(NotificationItem.fromJson)
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['items'] ?? data['Items'] ?? [];
      if (items is List) {
        return items
            .whereType<Map<String, dynamic>>()
            .map(NotificationItem.fromJson)
            .toList();
      }
    }
    return [];
  }

  void _mergeNotifications(List<NotificationItem> incoming) {
    if (incoming.isEmpty) return;

    final existingIds = _notifications
        .where((n) => n.id != null)
        .map((n) => n.id)
        .toSet();

    for (final item in incoming) {
      if (item.id == null || !existingIds.contains(item.id)) {
        _notifications.add(item);
      } else {
        final idx = _notifications.indexWhere((n) => n.id == item.id);
        if (idx != -1) {
          _notifications[idx] = item;
        }
      }
    }

    _notifications.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    notifyListeners();
  }

  void _updateLastCreatedAt(List<NotificationItem> items) {
    for (final item in items) {
      final createdAt = item.createdAt;
      if (createdAt == null) continue;
      if (_lastCreatedAt == null || createdAt.isAfter(_lastCreatedAt!)) {
        _lastCreatedAt = createdAt;
      }
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
