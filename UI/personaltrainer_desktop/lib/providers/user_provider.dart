import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personaltrainer_desktop/models/user.dart';
import 'package:personaltrainer_desktop/models/search_result.dart';
import 'package:personaltrainer_desktop/providers/base_provider.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("Users");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }

  @override
  Future<SearchResult<User>> get({dynamic filter}) async {
    try {
      return await super.get(filter: filter);
    } catch (e) {
      // Fallback: some APIs return a plain JSON array instead of a SearchResult wrapper
      var url = "${BaseProvider.baseUrl}Users";
      if (filter != null) {
        // Basic support for simple map filters
        if (filter is Map) {
          var qs = getQueryString(filter);
          url = "$url?$qs";
        }
      }

      var uri = Uri.parse(url);
      var headers = createHeaders();
      var response = await http.get(uri, headers: headers);

      if (response.statusCode < 299) {
        var data = jsonDecode(response.body);
        var result = SearchResult<User>();

        if (data is List) {
          result.count = data.length;
          for (var item in data) {
            result.result.add(fromJson(item));
          }
          return result;
        } else if (data is Map && data['items'] != null) {
          result.count = data['totalCount'] ?? 0;
          for (var item in data['items']) {
            result.result.add(fromJson(item));
          }
          return result;
        }
      }

      rethrow;
    }
  }

  Future<dynamic> login(String username, String password) async {
    var url = "${BaseProvider.baseUrl}Users/login";
    var uri = Uri.parse(url);

    var headers = {"Content-Type": "application/json"};

    var body = jsonEncode({"username": username, "password": password});

    var response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 204) {
      // Handle JWT response
      if (response.statusCode == 204 || response.body.isEmpty) {
        return {"success": true};
      }
      var data = jsonDecode(response.body);

      // Store the JWT token in AuthProvider
      AuthProvider.applyLoginResponse(data);

      return data;
    } else if (response.statusCode == 401) {
      throw Exception("Invalid username or password");
    } else {
      // Try to extract a meaningful error message (e.g. ban message)
      final body = response.body;
      if (body.isNotEmpty) {
        String? message;
        try {
          final decoded = jsonDecode(body);
          if (decoded is Map) {
            message =
                decoded['message']?.toString() ??
                decoded['Message']?.toString() ??
                decoded['detail']?.toString();
          }
        } catch (_) {
          // Plain string response
          message = body.trim().replaceAll('"', '');
        }
        if (message != null && message.isNotEmpty) {
          if (message.toLowerCase().contains('banned') ||
              message.toLowerCase().contains('ban')) {
            throw Exception('BANNED:$message');
          }
          if (message.toLowerCase().contains('deleted')) {
            throw Exception('DELETED:$message');
          }
          throw Exception(message);
        }
      }
      throw Exception("Login failed");
    }
  }

  Future<User?> getCurrentUser() async {
    if (AuthProvider.userId == null) return null;
    var url = "${BaseProvider.baseUrl}Users/${AuthProvider.userId}";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return User.fromJson(data);
    }
    return null;
  }

  Future<bool> updateUser(
    int userId,
    String firstName,
    String lastName,
    String email,
    String username,
    String phoneNumber,
    int? profileImageId,
  ) async {
    try {
      var url = "${BaseProvider.baseUrl}Users/update/$userId";
      var uri = Uri.parse(url);
      var headers = createHeaders();

      var body = jsonEncode({
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "username": username,
        "phoneNumber": phoneNumber,
        "isActive": true,
        "profileImageId": profileImageId,
        "roleIds": [],
      });

      var response = await http.put(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      var url = "${BaseProvider.baseUrl}Users/change-password";
      var uri = Uri.parse(url);
      var headers = createHeaders();

      var body = jsonEncode({
        "currentPassword": currentPassword,
        "newPassword": newPassword,
      });

      var response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      String errorMessage = 'Failed to change password.';
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map) {
            errorMessage = decoded['message']?.toString() ??
                decoded['Message']?.toString() ??
                errorMessage;
          }
        } catch (_) {
          errorMessage = response.body.trim().replaceAll('"', '');
        }
      }

      throw Exception(errorMessage);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to change password.');
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      var url = "${BaseProvider.baseUrl}Users/forgot-password";
      var uri = Uri.parse(url);

      var headers = {"Content-Type": "application/json"};

      var body = jsonEncode({"email": email});

      var response = await http.post(uri, headers: headers, body: body);

      // Backend returns 200 for both success and "email not found" cases for security
      if (response.statusCode == 200) {
        return true;
      } else {
        var errorMessage = "Unknown error";
        try {
          var errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['title'] ?? response.body;
        } catch (e) {
          errorMessage = response.body;
        }
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      var url = "${BaseProvider.baseUrl}Users/reset-password";
      var uri = Uri.parse(url);

      var headers = {"Content-Type": "application/json"};

      var body = jsonEncode({
        "token": token,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      });

      var response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode != 200) {
        return false;
      }

      return _isResetSuccessResponse(response.body);
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPasswordWithCode(
    String email,
    String verificationCode,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      var url = "${BaseProvider.baseUrl}Users/reset-password";
      var uri = Uri.parse(url);

      var headers = {"Content-Type": "application/json"};

      var body = jsonEncode({
        "Email": email,
        "Code": verificationCode,
        "NewPassword": newPassword,
        "ConfirmPassword": confirmPassword,
      });

      var response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode != 200) {
        return false;
      }

      return _isResetSuccessResponse(response.body);
    } catch (e) {
      return false;
    }
  }

  bool _isResetSuccessResponse(String body) {
    final trimmed = body.trim();

    if (trimmed.isEmpty) {
      return true;
    }

    if (trimmed.toLowerCase() == 'true') {
      return true;
    }

    if (trimmed.toLowerCase() == 'false') {
      return false;
    }

    try {
      final decoded = jsonDecode(trimmed);

      if (decoded is bool) {
        return decoded;
      }

      if (decoded is Map<String, dynamic>) {
        final successValue =
            decoded['success'] ?? decoded['isSuccess'] ?? decoded['result'];

        if (successValue is bool) {
          return successValue;
        }

        if (successValue is String) {
          final value = successValue.toLowerCase();
          if (value == 'true') {
            return true;
          }
          if (value == 'false') {
            return false;
          }
        }
      }
    } catch (e) {
      // If response format is unexpected, treat it as failure to avoid false positives.
    }

    return false;
  }
}
