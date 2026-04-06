import 'dart:convert';

class AuthProvider {
  static int? userId;
  static String? token;
  static final bool _isBanned = false;

  static bool get isBanned => _isBanned;

  static void applyLoginResponse(dynamic data) {
    // Accept different response shapes: a Map with Token/User, token/id, or a raw JWT string.
    if (data is Map<String, dynamic>) {
      // Handle backend response: { Token: "...", User: { id: ... } }
      if (data['Token'] != null || data['token'] != null) {
        token = (data['Token'] ?? data['token']) as String;

        // Try to get userId from User object first
        if (data['User'] != null && data['User'] is Map<String, dynamic>) {
          final user = data['User'] as Map<String, dynamic>;
          final userIdValue =
              user['id'] ?? user['Id'] ?? user['userId'] ?? user['UserId'];
          userId = int.tryParse(userIdValue?.toString() ?? '');
        } else if (data['id'] != null) {
          userId = int.tryParse(data['id'].toString());
        } else if (data['Id'] != null) {
          userId = int.tryParse(data['Id'].toString());
        } else if (data['userId'] != null) {
          userId = int.tryParse(data['userId'].toString());
        } else if (data['UserId'] != null) {
          userId = int.tryParse(data['UserId'].toString());
        }

        // If userId still not found, try to extract from JWT token
        if (userId == null) {
          _setUserIdFromToken(token!);
        }
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

  static String? _role;
  static String? get role => _role;

  static bool get isSuperAdmin => _role?.toLowerCase() == 'superadmin';

  static bool get isAdministrator => _role?.toLowerCase() == 'administrator';

  static dynamic _claimValue(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        return map[key];
      }
    }

    final lowerCaseMap = <String, dynamic>{};
    map.forEach((k, v) => lowerCaseMap[k.toLowerCase()] = v);

    for (final key in keys) {
      final value = lowerCaseMap[key.toLowerCase()];
      if (value != null) {
        return value;
      }
    }

    return null;
  }

  static void _setUserIdFromToken(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      final idVal = _claimValue(map, [
        'nameid',
        'sub',
        'userId',
        'UserId',
        'id',
        'Id',
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
        'http://schemas.microsoft.com/ws/2008/06/identity/claims/nameidentifier',
      ]);
      userId = idVal != null ? int.tryParse(idVal.toString()) : null;
      // Extract role from JWT claims
      final roleVal = _claimValue(map, [
        'role',
        'roles',
        'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/role',
      ]);
      if (roleVal is List) {
        _role = roleVal.isNotEmpty ? roleVal.first.toString() : null;
      } else if (roleVal != null) {
        _role = roleVal.toString();
      }
    } catch (_) {
      /* ignore parse errors */
    }
  }

  /// BriĹˇe sve korisniÄŤke podatke (logout)
  static void logout() {
    userId = null;
    token = null;
    _role = null;
  }

  /// Provjerava da li je korisnik ulogovan
  static bool get isLoggedIn => token != null && token!.isNotEmpty;
}

