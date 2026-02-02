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

    var headers = {
      "Content-Type": "application/json",
    };

    var body = jsonEncode({
      "username": username,
      "password": password,
    });

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
}
