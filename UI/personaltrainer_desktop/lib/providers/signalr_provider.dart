import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:personaltrainer_desktop/models/message.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart';
import 'package:http/http.dart' as http;

class SignalRProvider with ChangeNotifier {
  HubConnection? _hubConnection;
  final List<Message> _messages = [];
  final List<OnlineUser> _onlineUsers = [];
  bool _isConnected = false;
  String? _error;

  List<Message> get messages => _messages;
  List<OnlineUser> get onlineUsers => _onlineUsers;
  bool get isConnected => _isConnected;
  String? get error => _error;

  Future<void> connect() async {
    try {
      final token = AuthProvider.token;

      if (token == null || token.isEmpty) {
        _error = "No authentication token available";
        notifyListeners();
        return;
      }
      //Configure the SignalR connection with JWT Bearer token
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            "http://localhost:7093/hubs/presence",
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
              skipNegotiation: true,
              transport: HttpTransportType.WebSockets,
            ),
          )
          .withAutomaticReconnect()
          .build();

      // Register event handlers
      _registerHandlers();

      // Start the connection
      await _hubConnection!.start();
      _isConnected = true;
      _error = null;

      print("✅ SignalR Connected successfully");
      print("🔍 Connection ID: ${_hubConnection!.connectionId}");

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isConnected = false;
      print("❌ SignalR Connection error: $e");
      notifyListeners();
    }
  }

  void _registerHandlers() {
    print("🔍 DEBUG: Registering SignalR event handlers...");

    // Handle user coming online
    _hubConnection!.on("UserOnline", (arguments) {
      print("🔍 DEBUG: UserOnline event received! Arguments: $arguments");
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final rawData = arguments[0];
          OnlineUser? onlineUser;

          if (rawData is String) {
            onlineUser = OnlineUser(userId: rawData);
          } else if (rawData is int) {
            onlineUser = OnlineUser(userId: rawData.toString());
          } else if (rawData is Map<String, dynamic>) {
            onlineUser = OnlineUser.fromJson(rawData);
          }

          if (onlineUser != null) {
            if (!_onlineUsers.any((u) => u.userId == onlineUser!.userId)) {
              _onlineUsers.add(onlineUser);
              print("👤 User online: ${onlineUser.userId}");
              print("👥 Total online users now: ${_onlineUsers.length}");
              notifyListeners();
            }
          }
        } catch (e) {
          print("❌ Error parsing UserOnline: $e");
        }
      }
    });

    // Handle user going offline
    _hubConnection!.on("UserOffline", (arguments) {
      print("🔍 DEBUG: UserOffline event received! Arguments: $arguments");
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final rawData = arguments[0];
          String? userId;

          if (rawData is String) {
            userId = rawData;
          } else if (rawData is int) {
            userId = rawData.toString();
          } else if (rawData is Map<String, dynamic>) {
            userId =
                rawData['userId']?.toString() ?? rawData['UserId']?.toString();
          }

          if (userId != null) {
            _onlineUsers.removeWhere((u) => u.userId == userId);
            print("👤 User offline: $userId");
            print("👥 Total online users now: ${_onlineUsers.length}");
            notifyListeners();
          }
        } catch (e) {
          print("❌ Error parsing UserOffline: $e");
        }
      }
    });

    // Handle receiving a private message
    _hubConnection!.on("ReceivePrivateMessage", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0] as Map<String, dynamic>;
          final message = Message.fromJson(data);
          message.isPrivate = true;
          _messages.add(message);
          print("🔒 Private message received: ${message.message}");
          notifyListeners();
        } catch (e) {
          print("❌ Error parsing ReceivePrivateMessage: $e");
        }
      }
    });

    // Handle initial list of online users
    _hubConnection!.on("OnlineUsers", (arguments) {
      print("🔍 DEBUG: OnlineUsers event received! Arguments: $arguments");
      if (arguments != null && arguments.isNotEmpty) {
        try {
          _onlineUsers.clear();
          final rawData = arguments[0];

          if (rawData is List<dynamic>) {
            for (var item in rawData) {
              if (item is String) {
                _onlineUsers.add(OnlineUser(userId: item));
              } else if (item is Map<String, dynamic>) {
                final user = OnlineUser.fromJson(item);
                _onlineUsers.add(user);
              } else if (item is int) {
                _onlineUsers.add(OnlineUser(userId: item.toString()));
              }
            }
          }

          print("👥 Online users received: ${_onlineUsers.length}");
          print("👥 User IDs: ${_onlineUsers.map((u) => u.userId).toList()}");
          notifyListeners();
        } catch (e) {
          print("❌ Error parsing OnlineUsers: $e");
        }
      }
    });
    // Implement message polling if needed
  }

  Future<void> sendMessage(String message) async {
    if (!_isConnected) {
      _error = "Not connected";
      notifyListeners();
      return;
    }

    try {
      await _hubConnection!.invoke("SendMessage", args: [message]);
      print("📤 Message sent via SignalR: $message");
    } catch (e) {
      _error = e.toString();
      print("❌ Error sending message via SignalR: $e");
      notifyListeners();
    }
  }

  // Send message via HTTP endpoint (alternative to SignalR invoke)
  Future<void> sendMessageViaHttp(String message) async {
    final token = AuthProvider.token;

    if (token == null || token.isEmpty) {
      _error = "No authentication token available";
      notifyListeners();
      return;
    }

    try {
      final url = Uri.parse('https://localhost:7093/api/MessageTest/broadcast');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print("📤 HTTP Broadcast message sent: $message");
      } else {
        _error = "Failed to send message: ${response.statusCode}";
        print("❌ Error sending HTTP message: ${response.body}");
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      print("❌ Error sending HTTP message: $e");
      notifyListeners();
    }
  }

  Future<void> sendPrivateMessage(String toUserId, String message) async {
    // Use HTTP endpoint instead of SignalR invoke due to compatibility issues
    // with .NET 8.0 SignalR and signalr_netcore package
    final token = AuthProvider.token;

    if (token == null || token.isEmpty) {
      _error = "No authentication token available";
      notifyListeners();
      return;
    }

    try {
      final url = Uri.parse(
        'https://localhost:7093/hubs/presence/SendPrivateMessage',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'toUserId': toUserId, 'message': message}),
      );

      if (response.statusCode == 200) {
        // Add the sent message to local list
        _messages.add(
          Message(
            userId: AuthProvider.userId?.toString(),
            message: message,
            timestamp: DateTime.now(),
            toUserId: toUserId,
            isPrivate: true,
          ),
        );

        print("📤 Private message sent to $toUserId via HTTP: $message");
        notifyListeners();
      } else {
        _error = "Failed to send message: ${response.statusCode}";
        print("❌ Error sending private message: ${response.body}");
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      print("❌ Error sending private message: $e");
      notifyListeners();
    }
  }

  Future<void> refreshOnlineUsers() async {
    if (!_isConnected) {
      return;
    }
    print("🔄 Current online users: ${_onlineUsers.length} users online");
    print("🔄 User IDs: ${_onlineUsers.map((u) => u.userId).toList()}");
    notifyListeners();
  }

  Future<void> disconnect() async {
    if (_hubConnection != null) {
      try {
        await _hubConnection!.stop();
        _isConnected = false;
        _messages.clear();
        _onlineUsers.clear();
        print("🔌 SignalR Disconnected");
        notifyListeners();
      } catch (e) {
        print("❌ Error disconnecting: $e");
      }
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
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
