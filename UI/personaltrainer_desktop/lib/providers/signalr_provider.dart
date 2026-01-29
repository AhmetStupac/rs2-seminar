import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:personaltrainer_mobile/models/message.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
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
      final username = AuthProvider.username;
      final password = AuthProvider.password;

      if (username == null || password == null) {
        _error = "No authentication credentials available";
        notifyListeners();
        return;
      }

      // Create Basic Auth header
      final basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';

      // Configure the SignalR connection with Basic Auth
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            "https://localhost:7093/hubs/presence",
            options: HttpConnectionOptions(
              accessTokenFactory: () async => basicAuth,
              skipNegotiation: false,
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

      // Request current online users list
      try {
        final onlineUserIds = await getOnlineUsers();
        print("🔍 DEBUG: Fetched online users: $onlineUserIds");

        // Add current user to online list if not there
        final currentUserId = AuthProvider.userId?.toString();
        if (currentUserId != null &&
            !_onlineUsers.any((u) => u.userId == currentUserId)) {
          _onlineUsers.add(OnlineUser(userId: currentUserId));
          print("🔍 DEBUG: Added current user ($currentUserId) to online list");
        }
      } catch (e) {
        print("⚠️ Warning: Could not fetch online users: $e");
      }

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
          final data = arguments[0] as Map<String, dynamic>;
          print("🔍 DEBUG: UserOnline data: $data");
          final onlineUser = OnlineUser.fromJson(data);

          // Add user if not already in the list
          if (!_onlineUsers.any((u) => u.userId == onlineUser.userId)) {
            _onlineUsers.add(onlineUser);
            print(
              "👤 User online: ${onlineUser.email} (ID: ${onlineUser.userId})",
            );
            notifyListeners();
          }
        } catch (e) {
          print("❌ Error parsing UserOnline: $e");
        }
      }
    });

    // Handle user going offline
    _hubConnection!.on("UserOffline", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0] as Map<String, dynamic>;
          final userId = data['UserId'] as String?;

          if (userId != null) {
            _onlineUsers.removeWhere((u) => u.userId == userId);
            print("👤 User offline: ${data['Email']}");
            notifyListeners();
          }
        } catch (e) {
          print("Error parsing UserOffline: $e");
        }
      }
    });

    // Handle receiving a broadcast message
    _hubConnection!.on("ReceiveMessage", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0] as Map<String, dynamic>;
          final message = Message.fromJson(data);
          message.isPrivate = false;
          _messages.add(message);
          print("💬 Message received: ${message.message}");
          notifyListeners();
        } catch (e) {
          print("Error parsing ReceiveMessage: $e");
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
          print("Error parsing ReceivePrivateMessage: $e");
        }
      }
    });

    // Handle message sent confirmation
    _hubConnection!.on("MessageSent", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0] as Map<String, dynamic>;
          print("✅ Message sent confirmation: ${data['Message']}");
        } catch (e) {
          print("Error parsing MessageSent: $e");
        }
      }
    });

    // Handle message error
    _hubConnection!.on("MessageError", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final errorMsg = arguments[0] as String;
          _error = errorMsg;
          print("❌ Message error: $errorMsg");
          notifyListeners();
        } catch (e) {
          print("Error parsing MessageError: $e");
        }
      }
    });

    // Handle initial list of online users
    _hubConnection!.on("OnlineUsers", (arguments) {
      print("🔍 DEBUG: OnlineUsers event received! Arguments: $arguments");
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final userIds = (arguments[0] as List<dynamic>)
              .map((id) => id.toString())
              .toList();

          print("🔍 DEBUG: Parsed user IDs: $userIds");

          for (var userId in userIds) {
            if (!_onlineUsers.any((u) => u.userId == userId)) {
              _onlineUsers.add(OnlineUser(userId: userId));
              print("🔍 DEBUG: Added user $userId to online list");
            }
          }
          print("👥 Online users received: ${userIds.length}");
          print("🔍 DEBUG: Total online users now: ${_onlineUsers.length}");
          notifyListeners();
        } catch (e) {
          print("❌ Error parsing OnlineUsers: $e");
        }
      }
    });
  }

  Future<void> sendMessage(String message) async {
    if (!_isConnected || _hubConnection == null) {
      _error = "Not connected to SignalR hub";
      notifyListeners();
      return;
    }

    try {
      await _hubConnection!.invoke("SendMessage", args: [message]);
      print("📤 Broadcast message sent: $message");
    } catch (e) {
      _error = e.toString();
      print("❌ Error sending message: $e");
      notifyListeners();
    }
  }

  // Send message via HTTP endpoint (alternative to SignalR invoke)
  Future<void> sendMessageViaHttp(String message) async {
    final username = AuthProvider.username;
    final password = AuthProvider.password;

    if (username == null || password == null) {
      _error = "No authentication credentials available";
      notifyListeners();
      return;
    }

    try {
      final basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      final url = Uri.parse('https://localhost:7093/api/MessageTest/broadcast');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
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
    if (!_isConnected || _hubConnection == null) {
      _error = "Not connected to SignalR hub";
      notifyListeners();
      return;
    }

    try {
      await _hubConnection!.invoke(
        "SendPrivateMessage",
        args: [toUserId, message],
      );

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

      print("📤 Private message sent to $toUserId: $message");
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print("❌ Error sending private message: $e");
      notifyListeners();
    }
  }

  Future<List<String>> getOnlineUsers() async {
    if (!_isConnected || _hubConnection == null) {
      return [];
    }

    try {
      final result = await _hubConnection!.invoke("GetOnlineUsers");
      if (result != null && result is List) {
        return result.map((id) => id.toString()).toList();
      }
      return [];
    } catch (e) {
      print("❌ Error getting online users: $e");
      return [];
    }
  }

  // Refresh the online users list from the server
  Future<void> refreshOnlineUsers() async {
    if (!_isConnected || _hubConnection == null) {
      return;
    }

    try {
      // WORKAROUND: Don't call GetOnlineUsers due to package compatibility issues
      // Instead, rely on UserOnline/UserOffline events only
      // The backend already sends OnlineUsers list on connection
      print("🔄 Current online users: ${_onlineUsers.length} users online");
      print("🔄 User IDs: ${_onlineUsers.map((u) => u.userId).toList()}");

      // Just trigger a UI update
      notifyListeners();
    } catch (e) {
      print("❌ Error refreshing online users: $e");
    }
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
