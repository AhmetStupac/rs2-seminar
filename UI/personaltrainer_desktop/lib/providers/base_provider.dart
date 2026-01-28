import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:personaltrainer_mobile/models/search_result.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';
import 'package:personaltrainer_mobile/screens/banned_screen.dart'; // ⭐ Dodaj import

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  String _endpoint = "";
  
  // ⭐ SAMO navigator key (bez httpClient)
  static GlobalKey<NavigatorState>? navigatorKey;

  static String get baseUrl => _baseUrl ?? "https://localhost:7093/api/";

  static void initialize(GlobalKey<NavigatorState> navKey) {
    navigatorKey = navKey;
    print('BaseProvider initialized with navigator key');
  }

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "https://localhost:7093/api/",
    );
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = "$_baseUrl$_endpoint";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    print("🔍 GET Request to: $url");
    print("🔍 Headers: ${headers.keys.join(', ')}");
    print("🔍 Auth header value: ${headers['Authorization']}");

    var response = await http.get(uri, headers: headers);

    print("🔍 Response status: ${response.statusCode}");

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var result = SearchResult<T>();

      result.count = data['totalCount'] ?? 0;
      for (var item in data['items'] ?? []) {
        result.result.add(fromJson(item));
      }

      return result;
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> insert(dynamic request) async {
    var url = "$_baseUrl$_endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> update(int id, [dynamic request]) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      print("❌ 401 UNAUTHORIZED ERROR");
      print("❌ Request URL: ${response.request?.url}");
      print("❌ Response body: '${response.body}'");
      print("❌ Response headers: ${response.headers}");
      print("❌ Current username: ${AuthProvider.username}");
      print("❌ Current password set: ${AuthProvider.password != null && AuthProvider.password!.isNotEmpty}");
      throw Exception("Unauthorized");
    } else if (response.statusCode == 403) {
      // ⭐ Proveri da li je ban
      _handleBanRedirect(response);
      throw Exception("Access forbidden - User banned");
    } else {
      print(response.body);
      throw Exception("Something bad happened please try again");
    }
  }

  // ⭐ Handling bana
  void _handleBanRedirect(Response response) {
    try {
      final data = jsonDecode(response.body);
      final message = data['message']?.toString().toLowerCase() ?? '';
      
      if (message.contains('banovan') || message.contains('banned')) {
        print('🚫 User is banned! Redirecting to BannedScreen...');
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey?.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => BannedScreen(
                reason: data['reason'] ?? 'Nije naveden razlog',
                bannedAt: data['bannedAt'] != null 
                    ? DateTime.parse(data['bannedAt']) 
                    : null,
                expiresAt: data['expiresAt'] != null 
                    ? DateTime.parse(data['expiresAt']) 
                    : null,
                isPermanent: data['isPermanent'] ?? true,
              ),
            ),
            (route) => false,
          );
        });
      }
    } catch (e) {
      print('Error handling ban redirect: $e');
    }
  }

  Map<String, String> createHeaders() {
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";

    print("Creating headers with Basic Auth for user: $username");
    print("Password is ${password.isNotEmpty ? 'set (${password.length} chars)' : 'EMPTY'}");

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    print("Authorization header: $basicAuth");

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };

    return headers;
  }

  String getQueryString(
    Map params, {
    String prefix = '&',
    bool inRecursion = false,
  }) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = '[$key]';
        } else if (value is List || value is Map) {
          key = '.$key';
        } else {
          key = '.$key';
        }
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${value.toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query += getQueryString(
            {k: v},
            prefix: '$prefix$key',
            inRecursion: true,
          );
        });
      }
    });
    return query;
  }
}