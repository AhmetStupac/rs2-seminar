import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:personaltrainer_mobile/config/app_config.dart';
import 'package:personaltrainer_mobile/models/message.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MessagesProvider with ChangeNotifier {
  HubConnection? _hubConnection;
  final List<Message> _messages = [];
  final List<OnlineUser> _onlineUsers = [];
  bool _isConnected = false;
  String? _error;
  String? _currentRecipientId;

  List<Message> get messages => _messages;
  List<OnlineUser> get onlineUsers => _onlineUsers;
  bool get isConnected => _isConnected;
  String? get error => _error;
  String? get currentRecipientId => _currentRecipientId;

  // Get base URL for SignalR hubs
  // Use the same HTTP port as the API since everything runs through Docker on one port
  String get _hubBaseUrl {
    return AppConfig.signalRBaseUrl;
  }

  void setRecipient(String recipientId) {
    _currentRecipientId = recipientId;
    notifyListeners();
  }

  Future<void> connect(String recipientId) async {
    if (_isConnected && _currentRecipientId == recipientId) {
      return; // Already connected to this recipient
    }

    // Disconnect if connected to different recipient
    if (_isConnected && _currentRecipientId != recipientId) {
      await disconnect();
    }

    try {
      final token = AuthProvider.token;

      if (token == null || token.isEmpty) {
        _error = "No authentication token available";
        notifyListeners();
        return;
      }

      _currentRecipientId = recipientId;
      _messages.clear();

      final hubUrl = "$_hubBaseUrl/hubs/messages?userId=$recipientId";

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
              skipNegotiation: true,
              transport: HttpTransportType.WebSockets,
            ),
          )
          .withAutomaticReconnect()
          .build();

      _registerHandlers();

      await _hubConnection!.start();

      // Verify connection state before marking as connected
      if (_hubConnection!.state == HubConnectionState.Connected) {
        _isConnected = true;
        _error = null;

        // Give backend time to send initial message thread
        await Future.delayed(const Duration(milliseconds: 500));

        if (_messages.isEmpty) {
        }
      } else {
        _isConnected = false;
        _error = "Failed to establish connection";
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isConnected = false;
      notifyListeners();
    }
  }

  void _registerHandlers() {

    // Add a catch-all handler to see ALL events from backend
    _hubConnection!.onclose(({error}) {
      _isConnected = false;
      notifyListeners();
    });

    // Log all incoming methods

    // Handle initial message thread - try multiple event names
    void handleMessageThread(List<dynamic>? arguments) {

      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0];

          if (data is List) {
            _messages.clear();
            for (var item in data) {
              final message = Message.fromJson(item as Map<String, dynamic>);
              _messages.add(message);
            }
          } else if (data == null || (data is List && data.isEmpty)) {
            _messages.clear();
          } else {
          }
          notifyListeners();
        } catch (e, stackTrace) {
        }
      } else {
        _messages.clear();
        notifyListeners();
      }
    }

    _hubConnection!.on("ReceiveMessageThread", handleMessageThread);
    _hubConnection!.on("receiveMessageThread", handleMessageThread);

    // Handle new incoming messages - try multiple event names
    void handleNewMessage(List<dynamic>? arguments) {

      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0] as Map<String, dynamic>;
          final message = Message.fromJson(data);
          _messages.add(message);
          notifyListeners();
        } catch (e, stackTrace) {
        }
      }
    }

    _hubConnection!.on("New message", handleNewMessage);
    _hubConnection!.on("new message", handleNewMessage);
    _hubConnection!.on("NewMessage", handleNewMessage);

  }

  Future<void> sendMessage(String content) async {
    if (_hubConnection == null ||
        _hubConnection!.state != HubConnectionState.Connected) {
      _error = "Not connected. Please wait or reconnect.";
      _isConnected = false;
      notifyListeners();
      return;
    }

    if (!_isConnected) {
      _error = "Not connected. Please select a user to message.";
      notifyListeners();
      return;
    }

    if (_currentRecipientId == null) {
      _error = "No recipient selected";
      notifyListeners();
      return;
    }

    try {
      final token = AuthProvider.token;
      if (token == null || token.isEmpty) {
        _error = "No authentication token available";
        notifyListeners();
        return;
      }

      // Create DTO matching backend CreateMessageDTO
      final messageDto = {
        'recipientId': _currentRecipientId,
        'content': content,
      };


      // Use HTTP POST instead of SignalR invoke due to compatibility issues
      final url = Uri.parse('${BaseProvider.baseUrl}Message/send');

      final response = await BaseProvider.client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(messageDto),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Don't add locally - backend will broadcast via SignalR
      } else {
        _error =
            "Failed to send message: ${response.statusCode} - ${response.body}";
        notifyListeners();
      }
    } catch (e, stackTrace) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void setOnlineUsers(List<OnlineUser> users) {
    _onlineUsers.clear();
    _onlineUsers.addAll(users);
    notifyListeners();
  }

  Future<void> disconnect() async {
    if (_hubConnection != null) {
      try {
        await _hubConnection!.stop();
        _isConnected = false;
        _currentRecipientId = null;
        _messages.clear();
        notifyListeners();
      } catch (e) {
      }
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
