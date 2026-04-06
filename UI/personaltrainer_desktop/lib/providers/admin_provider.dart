import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:personaltrainer_desktop/config/app_config.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart'; // â­ Dodaj import

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

  // â­ Banovanje korisnika
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
        return {'success': true, 'message': 'Korisnik uspeĹˇno banovan'};
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Pristup zabranjen',
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Korisnik nije pronaÄ‘en'};
      } else {
        return {'success': false, 'message': 'GreĹˇka: ${response.statusCode}'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'GreĹˇka pri komunikaciji sa serverom: $e',
      };
    }
  }

  // Unbanovanje korisnika
  Future<Map<String, dynamic>> unbanUser(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}users/unban-user/$userId'),
        headers: _createHeaders(),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Korisnik uspeĹˇno unbanovan'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Korisnik nije pronaÄ‘en'};
      } else {
        return {'success': false, 'message': 'GreĹˇka: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'GreĹˇka: $e'};
    }
  }

  // Provera ban statusa
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
          'message': 'GreĹˇka pri proveri bana',
        };
      }
    } catch (e) {
      return {'success': false, 'isBanned': false, 'message': 'GreĹˇka: $e'};
    }
  }

  // Dobavi sve korisnike
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final requestUrl = '${_apiBaseUrl}users';
      final response = await _getWithProtocolFallback(requestUrl);

      if (response.statusCode != 200) {
      }

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        // Proveri da li je response lista ili objekat sa 'items'
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

  // Dobavi sve obrisane korisnike
  Future<List<Map<String, dynamic>>> getDeletedUsers() async {
    try {
      final requestUrl = '${_apiBaseUrl}users/deleted';
      final response = await _getWithProtocolFallback(requestUrl);

      if (response.statusCode != 200) {
      }

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        // Proveri da li je response lista ili objekat sa 'items'
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

  // Soft delete korisnika
  Future<Map<String, dynamic>> softDeleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}users/soft/$userId'),
        headers: _createHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Ako je prazan body ili 204, vrati uspeh
        if (response.body.isEmpty) {
          return {'success': true, 'message': 'Korisnik uspeĹˇno obrisan'};
        }
        // Ako ima body, pokuĹˇaj da ga parsiraĹˇ
        try {
          final data = jsonDecode(response.body);
          return {
            'success': true,
            'message': data['message'] ?? 'Korisnik uspeĹˇno obrisan',
          };
        } catch (_) {
          return {'success': true, 'message': 'Korisnik uspeĹˇno obrisan'};
        }
      } else if (response.statusCode == 403) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'Pristup zabranjen',
          };
        }
        return {'success': false, 'message': 'Pristup zabranjen'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Korisnik nije pronaÄ‘en'};
      } else {
        return {'success': false, 'message': 'GreĹˇka: ${response.statusCode}'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'GreĹˇka pri komunikaciji sa serverom: $e',
      };
    }
  }

  // Restore obrisanog korisnika
  Future<Map<String, dynamic>> restoreUser(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}users/restore/$userId'),
        headers: _createHeaders(),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Korisnik uspeĹˇno vraÄ‡en'};
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Pristup zabranjen',
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Korisnik nije pronaÄ‘en'};
      } else {
        return {'success': false, 'message': 'GreĹˇka: ${response.statusCode}'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'GreĹˇka pri komunikaciji sa serverom: $e',
      };
    }
  }
}

