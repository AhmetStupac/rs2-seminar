import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:personaltrainer_desktop/providers/auth_provider.dart'; // ⭐ Dodaj import

class AdminProvider {
  final String baseUrl = const String.fromEnvironment(
    "baseUrl",
    defaultValue: "https://localhost:7093/api/",
  );

  // Create headers with JWT Bearer token
  Map<String, String> _createHeaders() {
    String token = AuthProvider.token ?? "";

    print("AdminProvider using JWT token: ${token.isNotEmpty ? 'present' : 'missing'}");

    var headers = {
      "Content-Type": "application/json",
    };

    if (token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  // ⭐ Banovanje korisnika
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
        return {
          'success': true,
          'message': 'Korisnik uspešno banovan',
        };
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Pristup zabranjen',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Korisnik nije pronađen',
        };
      } else {
        return {
          'success': false,
          'message': 'Greška: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error in banUser: $e');
      return {
        'success': false,
        'message': 'Greška pri komunikaciji sa serverom: $e',
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
        return {
          'success': true,
          'message': 'Korisnik uspešno unbanovan',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Korisnik nije pronađen',
        };
      } else {
        return {
          'success': false,
          'message': 'Greška: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error in unbanUser: $e');
      return {
        'success': false,
        'message': 'Greška: $e',
      };
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
          'message': 'Greška pri proveri bana',
        };
      }
    } catch (e) {
      print('Error in checkBan: $e');
      return {
        'success': false,
        'isBanned': false,
        'message': 'Greška: $e',
      };
    }
  }

  // Dobavi sve korisnike
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      print('Calling getAllUsers endpoint...');
      final response = await http.get(
        Uri.parse('${baseUrl}users'),
        headers: _createHeaders(),
      );

      print('getAllUsers response status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('getAllUsers error body: ${response.body}');
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
      print('Error in getAllUsers: $e');
      return [];
    }
  }

  // Dobavi sve obrisane korisnike
  Future<List<Map<String, dynamic>>> getDeletedUsers() async {
    try {
      print('Calling getDeletedUsers endpoint...');
      final response = await http.get(
        Uri.parse('${baseUrl}users/deleted'),
        headers: _createHeaders(),
      );

      print('getDeletedUsers response status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('getDeletedUsers error body: ${response.body}');
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
      print('Error in getDeletedUsers: $e');
      return [];
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
          return {
            'success': true,
            'message': 'Korisnik uspešno obrisan',
          };
        }
        // Ako ima body, pokušaj da ga parsiraš
        try {
          final data = jsonDecode(response.body);
          return {
            'success': true,
            'message': data['message'] ?? 'Korisnik uspešno obrisan',
          };
        } catch (_) {
          return {
            'success': true,
            'message': 'Korisnik uspešno obrisan',
          };
        }
      } else if (response.statusCode == 403) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'Pristup zabranjen',
          };
        }
        return {
          'success': false,
          'message': 'Pristup zabranjen',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Korisnik nije pronađen',
        };
      } else {
        return {
          'success': false,
          'message': 'Greška: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error in softDeleteUser: $e');
      return {
        'success': false,
        'message': 'Greška pri komunikaciji sa serverom: $e',
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
        return {
          'success': true,
          'message': 'Korisnik uspešno vraćen',
        };
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Pristup zabranjen',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Korisnik nije pronađen',
        };
      } else {
        return {
          'success': false,
          'message': 'Greška: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error in restoreUser: $e');
      return {
        'success': false,
        'message': 'Greška pri komunikaciji sa serverom: $e',
      };
      }
  }
}