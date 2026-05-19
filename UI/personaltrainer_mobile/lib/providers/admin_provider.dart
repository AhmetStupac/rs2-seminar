import 'dart:convert';
import 'package:personaltrainer_mobile/config/app_config.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';

class AdminProvider {
  final String baseUrl = AppConfig.apiBaseUrl;

  // Create headers with JWT Bearer token
  Map<String, String> _createHeaders() {
    String token = AuthProvider.token ?? "";


    var headers = {"Content-Type": "application/json"};

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
      final response = await BaseProvider.client.post(
        Uri.parse('${baseUrl}users/ban-user'),
        headers: _createHeaders(),
        body: jsonEncode({
          'userId': userId,
          'reason': reason,
          'expiresAt': expiresAt?.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Korisnik uspešno banovan'};
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Pristup zabranjen',
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Korisnik nije pronađen'};
      } else {
        return {'success': false, 'message': 'Greška: ${response.statusCode}'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Greška pri komunikaciji sa serverom: $e',
      };
    }
  }

  // Unbanovanje korisnika
  Future<Map<String, dynamic>> unbanUser(int userId) async {
    try {
      final response = await BaseProvider.client.post(
        Uri.parse('${baseUrl}users/unban-user/$userId'),
        headers: _createHeaders(),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Korisnik uspešno unbanovan'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Korisnik nije pronađen'};
      } else {
        return {'success': false, 'message': 'Greška: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Greška: $e'};
    }
  }

  // Provera ban statusa
  Future<Map<String, dynamic>> checkBan(int userId) async {
    try {
      final response = await BaseProvider.client.get(
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
      return {'success': false, 'isBanned': false, 'message': 'Greška: $e'};
    }
  }

  // Dobavi sve korisnike
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await BaseProvider.client.get(
        Uri.parse('${baseUrl}users'),
        headers: _createHeaders(),
      );

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
      return [];
    }
  }

  // Dobavi sve obrisane korisnike
  Future<List<Map<String, dynamic>>> getDeletedUsers() async {
    try {
      final response = await BaseProvider.client.get(
        Uri.parse('${baseUrl}users/deleted'),
        headers: _createHeaders(),
      );

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
      return [];
    }
  }

  // Soft delete korisnika
  Future<Map<String, dynamic>> softDeleteUser(int userId) async {
    try {
      final response = await BaseProvider.client.delete(
        Uri.parse('${baseUrl}users/soft/$userId'),
        headers: _createHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Ako je prazan body ili 204, vrati uspeh
        if (response.body.isEmpty) {
          return {'success': true, 'message': 'Korisnik uspešno obrisan'};
        }
        // Ako ima body, pokušaj da ga parsiraš
        try {
          final data = jsonDecode(response.body);
          return {
            'success': true,
            'message': data['message'] ?? 'Korisnik uspešno obrisan',
          };
        } catch (_) {
          return {'success': true, 'message': 'Korisnik uspešno obrisan'};
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
        return {'success': false, 'message': 'Korisnik nije pronađen'};
      } else {
        return {'success': false, 'message': 'Greška: ${response.statusCode}'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Greška pri komunikaciji sa serverom: $e',
      };
    }
  }

  // Restore obrisanog korisnika
  Future<Map<String, dynamic>> restoreUser(int userId) async {
    try {
      final response = await BaseProvider.client.post(
        Uri.parse('${baseUrl}users/restore/$userId'),
        headers: _createHeaders(),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Korisnik uspešno vraćen'};
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Pristup zabranjen',
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Korisnik nije pronađen'};
      } else {
        return {'success': false, 'message': 'Greška: ${response.statusCode}'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Greška pri komunikaciji sa serverom: $e',
      };
    }
  }

  // Trainer dashboard (Administrator / PersonalTrainer – own stats only)
  Future<Map<String, dynamic>?> getTrainerDashboard() async {
    try {
      final response = await BaseProvider.client.get(
        Uri.parse('${baseUrl}dashboard/trainer-dashboard'),
        headers: _createHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Dashboard report (SuperAdmin only)
  Future<Map<String, dynamic>?> getDashboardReport() async {
    try {
      final response = await BaseProvider.client.get(
        Uri.parse('${baseUrl}dashboard/report'),
        headers: _createHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
