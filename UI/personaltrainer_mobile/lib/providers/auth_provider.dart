import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider {
  static int? userId;
  static String? token;
  static bool _isBanned = false;

  static bool get isBanned => _isBanned;

  /// Global navigator key — set on MaterialApp so we can navigate without context.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Registered by main.dart. Called on 401 to redirect user to login.
  static VoidCallback? onUnauthorized;

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyToken = 'auth_token';
  static const _keyUserId = 'auth_user_id';

  // ── Persistence ────────────────────────────────────────────────────────────

  /// Call once at app start-up before runApp.
  /// Returns true if a valid stored session was found.
  static Future<bool> loadFromStorage() async {
    try {
      final storedToken = await _storage.read(key: _keyToken);
      final storedId = await _storage.read(key: _keyUserId);
      debugPrint('[AuthProvider] loadFromStorage: token=${storedToken?.isNotEmpty} userId=$storedId');
      if (storedToken != null && storedToken.isNotEmpty) {
        token = storedToken;
        userId = storedId != null ? int.tryParse(storedId) : null;
        return true;
      }
    } catch (e) {
      debugPrint('[AuthProvider] loadFromStorage ERROR: $e');
    }
    return false;
  }

  static Future<void> _saveToStorage() async {
    try {
      await _storage.write(key: _keyToken, value: token ?? '');
      await _storage.write(key: _keyUserId, value: userId?.toString() ?? '');
      debugPrint('[AuthProvider] _saveToStorage: saved token=${token?.isNotEmpty} userId=$userId');
    } catch (e) {
      debugPrint('[AuthProvider] _saveToStorage ERROR: $e');
    }
  }

  static Future<void> _clearStorage() async {
    try {
      await _storage.delete(key: _keyToken);
      await _storage.delete(key: _keyUserId);
    } catch (_) {}
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  static Future<void> applyLoginResponse(dynamic data) async {
    if (data is Map<String, dynamic>) {
      if (data['Token'] != null || data['token'] != null) {
        token = (data['Token'] ?? data['token']) as String;

        if (data['User'] != null && data['User'] is Map<String, dynamic>) {
          final user = data['User'] as Map<String, dynamic>;
          userId = int.tryParse(user['id']?.toString() ?? '');
        } else if (data['id'] != null) {
          userId = int.tryParse(data['id'].toString());
        }

        if (userId == null) {
          _setUserIdFromToken(token!);
        }
      }
    } else if (data is String) {
      token = data;
      _setUserIdFromToken(token!);
    }

    await _saveToStorage();
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
    } catch (_) {}
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  static Future<void> logout() async {
    userId = null;
    token = null;
    _isBanned = false;
    await _clearStorage();
  }

  /// Called by BaseProvider on a 401 response.
  /// Clears the session and fires the onUnauthorized callback registered by main.dart.
  static Future<void> triggerUnauthorized() async {
    await logout();
    onUnauthorized?.call();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static bool get isLoggedIn => token != null && token!.isNotEmpty;
}
