import 'dart:convert';

class AuthProvider {
  static String? username;
  static String? password;
  static int? userId;
  static String? token;

  static void applyLoginResponse(dynamic data) {
    // Accept different response shapes: a Map with id/token, or a raw JWT string.
    if (data is Map<String, dynamic>) {
      if (data['id'] != null) {
        userId = int.tryParse(data['id'].toString());
      }
      if (data['token'] != null) {
        token = data['token'] as String;
        _setUserIdFromToken(token!);
      }
      return;
    }

    if (data is String) {
      // treat string as JWT token
      token = data;
      _setUserIdFromToken(token!);
      return;
    }

    // unsupported type (e.g., SearchResult<Exercise>) -> ignore silently
  }

  static void _setUserIdFromToken(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      final idVal = map['nameid'] ?? map['sub'] ?? map['userId'];
      userId = idVal != null ? int.tryParse(idVal.toString()) : null;
    } catch (_) {
      /* ignore parse errors */
    }
  }
}
