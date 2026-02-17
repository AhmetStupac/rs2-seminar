import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personaltrainer_mobile/models/user.dart';
import 'package:personaltrainer_mobile/models/search_result.dart';
import 'package:personaltrainer_mobile/providers/base_provider.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';

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

    print("🔐 Attempting login to: $url");
    print("🔐 Username: $username");

    var response = await http.post(uri, headers: headers, body: body);

    print("🔐 Login response status: ${response.statusCode}");
    print("🔐 Login response body: ${response.body}");

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
      throw Exception("Login failed: ${response.body}");
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

      print("🔄 Updating user: $userId");
      print("🔄 URL: $url");
      var response = await http.put(uri, headers: headers, body: body);
      print("🔄 Update user response status: ${response.statusCode}");
      print("🔄 Update user response body: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ User updated successfully");
        return true;
      } else {
        print("❌ Failed to update user: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error updating user: $e");
      print("❌ Error type: ${e.runtimeType}");
      return false;
    }
  }

  Future<bool> changePassword(int userId, String newPassword) async {
    try {
      // First, get the current user data
      var currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception("User not found");
      }

      // Prepare the update request with current user data + new password
      var url = "${BaseProvider.baseUrl}Users/update/$userId";
      var uri = Uri.parse(url);
      var headers = createHeaders();

      var body = jsonEncode({
        "firstName": currentUser.firstName,
        "lastName": currentUser.lastName,
        "email": currentUser.email,
        "username": currentUser.username,
        "phoneNumber": currentUser.phoneNumber,
        "isActive": currentUser.isActive ?? true,
        "password": newPassword,
        "roleIds": [], // Empty array to maintain current roles
      });

      print("🔑 Changing password for user: $userId");
      var response = await http.put(uri, headers: headers, body: body);
      print("🔑 Change password response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✅ Password changed successfully");
        return true;
      } else {
        print("❌ Failed to change password: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error changing password: $e");
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      var url = "${BaseProvider.baseUrl}Users/forgot-password";
      var uri = Uri.parse(url);

      var headers = {"Content-Type": "application/json"};

      var body = jsonEncode({"email": email});

      print("📧 Sending password reset email to: $email");
      print("📧 URL: $url");
      print("📧 Request body: $body");

      var response = await http.post(uri, headers: headers, body: body);

      print("📧 Forgot password response status: ${response.statusCode}");
      print("📧 Forgot password response body: ${response.body}");

      // Backend returns 200 for both success and "email not found" cases for security
      if (response.statusCode == 200) {
        print("✅ Password reset email sent successfully");
        return true;
      } else {
        print("❌ Failed to send password reset email: ${response.body}");
        var errorMessage = "Unknown error";
        try {
          var errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['title'] ?? response.body;
        } catch (e) {
          errorMessage = response.body;
        }
        print("❌ Error details: $errorMessage");
        return false;
      }
    } catch (e) {
      print("❌ Error sending password reset email: $e");
      print("❌ Error type: ${e.runtimeType}");
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

      print("🔑 Resetting password with token");
      var response = await http.post(uri, headers: headers, body: body);
      print("🔑 Reset password response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✅ Password reset successfully");
        return true;
      } else {
        print("❌ Failed to reset password: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error resetting password: $e");
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

      print("🔑 Resetting password with verification code for: $email");
      print("🔑 URL: $url");
      var response = await http.post(uri, headers: headers, body: body);
      print("🔑 Reset password response status: ${response.statusCode}");
      print("🔑 Reset password response body: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ Password reset successfully");
        return true;
      } else {
        print("❌ Failed to reset password: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error resetting password: $e");
      print("❌ Error type: ${e.runtimeType}");
      return false;
    }
  }
}
