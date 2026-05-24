import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:personaltrainer_mobile/models/user.dart';
import 'package:personaltrainer_mobile/models/search_result.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
import 'package:personaltrainer_mobile/utils/api_error.dart';

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
      var response = await BaseProvider.client.get(uri, headers: headers);

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

    debugPrint('Login: POST $url');

    var response = await BaseProvider.client.post(
      uri,
      headers: headers,
      body: body,
    );

    debugPrint('Login: response ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      // Handle JWT response
      if (response.statusCode == 204 || response.body.isEmpty) {
        return {"success": true};
      }
      var data = jsonDecode(response.body);

      // Store the JWT token in AuthProvider
      await AuthProvider.applyLoginResponse(data);

      return data;
    } else if (response.statusCode == 401) {
      throw Exception("Invalid username or password.");
    } else {
      throw Exception(
        ApiError.fromBody(response.body, statusCode: response.statusCode),
      );
    }
  }

  Future<User> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    String? phoneNumber,
    required String password,
  }) async {
    final request = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'password': password,
    };

    final phone = phoneNumber?.trim();
    if (phone != null && phone.isNotEmpty) {
      request['phoneNumber'] = phone;
    }

    final url = '${BaseProvider.baseUrl}Users/register';
    final uri = Uri.parse(url);
    final response = await BaseProvider.client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return fromJson(jsonDecode(response.body));
    }

    throw Exception(
      ApiError.fromBody(
        response.body,
        statusCode: response.statusCode,
        fallback: 'Registration failed.',
      ),
    );
  }

  Future<User?> getCurrentUser() async {
    if (AuthProvider.userId == null) return null;
    var url = "${BaseProvider.baseUrl}Users/${AuthProvider.userId}";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await BaseProvider.client.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return User.fromJson(data);
    }
    return null;
  }

  Future<void> updateUser(
    int userId,
    String firstName,
    String lastName,
    String email,
    String username,
    String phoneNumber, {
    int? profileImageId,
  }) async {
    var url = "${BaseProvider.baseUrl}Users/update/$userId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var body = <String, dynamic>{
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "username": username,
      "phoneNumber": phoneNumber,
      "isActive": true,
      "roleIds": [],
    };
    if (profileImageId != null) {
      body["profileImageId"] = profileImageId;
    }

    var response = await BaseProvider.client.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        ApiError.fromBody(response.body,
            statusCode: response.statusCode,
            fallback: 'Failed to update profile.'),
      );
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    var url = "${BaseProvider.baseUrl}Users/change-password";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var body = jsonEncode({
      "currentPassword": currentPassword,
      "newPassword": newPassword,
    });

    var response = await BaseProvider.client.post(
      uri,
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        ApiError.fromBody(response.body,
            statusCode: response.statusCode,
            fallback: 'Failed to change password.'),
      );
    }
  }

  /// Backend returns 200 for both "sent" and "email not found" cases (security).
  /// Non-200 responses indicate a real server error and are thrown.
  Future<void> forgotPassword(String email) async {
    var url = "${BaseProvider.baseUrl}Users/forgot-password";
    var uri = Uri.parse(url);
    var headers = {"Content-Type": "application/json"};
    var body = jsonEncode({"email": email});

    var response = await BaseProvider.client.post(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception(
        ApiError.fromBody(response.body,
            statusCode: response.statusCode,
            fallback: 'Failed to send reset code. Please try again.'),
      );
    }
  }

  Future<void> resetPasswordWithCode(
    String email,
    String verificationCode,
    String newPassword,
    String confirmPassword,
  ) async {
    if (newPassword != confirmPassword) {
      throw Exception('Passwords do not match.');
    }

    var url = "${BaseProvider.baseUrl}Users/reset-password";
    var uri = Uri.parse(url);
    var headers = {"Content-Type": "application/json"};
    var body = jsonEncode({
      "Email": email,
      "Code": verificationCode,
      "NewPassword": newPassword,
    });

    var response = await BaseProvider.client.post(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception(
        ApiError.fromBody(response.body,
            statusCode: response.statusCode,
            fallback: 'Invalid or expired verification code.'),
      );
    }
  }
}
