import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:personaltrainer_desktop/config/app_config.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart';

class AdminProvider {
  final String baseUrl = AppConfig.apiBaseUrl;

  String get _apiBaseUrl => baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

  bool _isWrongTlsVersionError(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('handshakeexception') &&
        msg.contains('wrong_version_number');
  }

  Uri _toggleHttpScheme(Uri uri) {
    final toggledScheme = uri.scheme == 'https' ? 'http' : 'https';
    return uri.replace(scheme: toggledScheme);
  }

  Future<http.Response> _getWithProtocolFallback(String url) async {
    final headers = _createHeaders();
    final uri = Uri.parse(url);

    try {
      return await http.get(uri, headers: headers);
    } catch (e) {
      if (!_isWrongTlsVersionError(e)) rethrow;

      final fallbackUri = _toggleHttpScheme(uri);
      return await http.get(fallbackUri, headers: headers);
    }
  }

  // Create headers with JWT Bearer token
  Map<String, String> _createHeaders() {
    String token = AuthProvider.token ?? "";

    var headers = {"Content-Type": "application/json"};

    if (token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  // Ban user
  Future<Map<String, dynamic>> banUser({
    required int userId,
    required String reason,
    DateTime? expiresAt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}users/ban-user'),
        headers: _createHeaders(),
        body: jsonEncode({
          'userId': userId,
          'reason': reason,
          'expiresAt': expiresAt?.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'User banned successfully'};
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Access denied',
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'User not found'};
      } else {
        return {'success': false, 'message': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Server communication error: $e'};
    }
  }

  // Unban user
  Future<Map<String, dynamic>> unbanUser(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}users/unban-user/$userId'),
        headers: _createHeaders(),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'User unbanned successfully'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'User not found'};
      } else {
        return {'success': false, 'message': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Check ban status
  Future<Map<String, dynamic>> checkBan(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}users/check-ban/$userId'),
        headers: _createHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'isBanned': data['isBanned'] ?? false,
          'reason': data['reason'],
          'bannedAt': data['bannedAt'] != null
              ? DateTime.parse(data['bannedAt'])
              : null,
          'expiresAt': data['expiresAt'] != null
              ? DateTime.parse(data['expiresAt'])
              : null,
          'isPermanent': data['isPermanent'] ?? false,
        };
      } else {
        return {
          'success': false,
          'isBanned': false,
          'message': 'Error checking ban status',
        };
      }
    } catch (e) {
      return {'success': false, 'isBanned': false, 'message': 'Error: $e'};
    }
  }

  // Fetch all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final requestUrl = '${_apiBaseUrl}users';
      final response = await _getWithProtocolFallback(requestUrl);

      if (response.statusCode != 200) {}

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        // Check if response is a list or an object with 'items'
        if (decodedData is List) {
          return decodedData.cast<Map<String, dynamic>>();
        } else if (decodedData is Map && decodedData['items'] != null) {
          final List<dynamic> items = decodedData['items'];
          return items.cast<Map<String, dynamic>>();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Fetch all deleted users
  Future<List<Map<String, dynamic>>> getDeletedUsers() async {
    try {
      final requestUrl = '${_apiBaseUrl}users/deleted';
      final response = await _getWithProtocolFallback(requestUrl);

      if (response.statusCode != 200) {}

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        // Check if response is a list or an object with 'items'
        if (decodedData is List) {
          return decodedData.cast<Map<String, dynamic>>();
        } else if (decodedData is Map && decodedData['items'] != null) {
          final List<dynamic> items = decodedData['items'];
          return items.cast<Map<String, dynamic>>();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load deleted users: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Soft delete user
  Future<Map<String, dynamic>> softDeleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}users/soft/$userId'),
        headers: _createHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // If body is empty or 204, return success
        if (response.body.isEmpty) {
          return {'success': true, 'message': 'User deleted successfully'};
        }
        // If body exists, try to parse it
        try {
          final data = jsonDecode(response.body);
          return {
            'success': true,
            'message': data['message'] ?? 'User deleted successfully',
          };
        } catch (_) {
          return {'success': true, 'message': 'User deleted successfully'};
        }
      } else if (response.statusCode == 403) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'Access denied',
          };
        }
        return {'success': false, 'message': 'Access denied'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'User not found'};
      } else {
        return {'success': false, 'message': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Server communication error: $e'};
    }
  }

  // Restore deleted user
  Future<Map<String, dynamic>> restoreUser(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}users/restore/$userId'),
        headers: _createHeaders(),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'User restored successfully'};
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Access denied',
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'User not found'};
      } else {
        return {'success': false, 'message': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Server communication error: $e'};
    }
  }
}
