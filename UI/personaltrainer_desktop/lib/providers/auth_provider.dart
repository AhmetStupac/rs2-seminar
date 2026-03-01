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
          userId = int.tryParse(user['id']?.toString() ?? '');
        } else if (data['id'] != null) {
          userId = int.tryParse(data['id'].toString());
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

  static bool get isSuperAdmin =>
      _role?.toLowerCase() == 'superadmin';

  static bool get isAdministrator =>
      _role?.toLowerCase() == 'administrator';

  static void _setUserIdFromToken(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      print('🔑 JWT claims keys: ${map.keys.toList()}');
      final idVal = map['nameid'] ?? map['sub'] ?? map['userId'];
      userId = idVal != null ? int.tryParse(idVal.toString()) : null;
      // Extract role from JWT claims
      final roleVal = map['role'] ??
          map['roles'] ??
          map['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
      if (roleVal is List) {
        _role = roleVal.isNotEmpty ? roleVal.first.toString() : null;
      } else if (roleVal != null) {
        _role = roleVal.toString();
      }
      print('🔑 Extracted role: $_role | userId: $userId');
    } catch (_) {
      /* ignore parse errors */
    }
  }

  /// Briše sve korisničke podatke (logout)
  static void logout() {
    userId = null;
    token = null;
    _role = null;
  }

  /// Provjerava da li je korisnik ulogovan
  static bool get isLoggedIn => token != null && token!.isNotEmpty;

 

  
}
