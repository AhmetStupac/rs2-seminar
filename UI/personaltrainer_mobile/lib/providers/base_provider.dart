import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:personaltrainer_mobile/models/search_result.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  String _endpoint = "";
  static http.Client? _client;

  static String get baseUrl => _baseUrl ?? "http://10.0.2.2:7093/api/";

  static http.Client get client {
    if (_client == null) {
      // Create HttpClient that accepts self-signed certificates for development
      final ioClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      _client = IOClient(ioClient);
    }
    return _client!;
  }

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://10.0.2.2:7093/api/",
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

    var response = await client.get(uri, headers: headers);

    print("🔍 Response status: ${response.statusCode}");
    print(
      "🔍 Response body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}",
    );

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
    var response = await client.post(uri, headers: headers, body: jsonRequest);

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
    var response = await client.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<void> delete(int id) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await client.delete(uri, headers: headers);

    if (!isValidResponse(response)) {
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
      print(
        "❌ Current token set: ${AuthProvider.token != null && AuthProvider.token!.isNotEmpty}",
      );
      throw Exception("Unauthorized");
    } else if (response.statusCode == 403) {
      // ⭐ Proveri da li je ban
      _handleBanRedirect(response);
      throw Exception("Access forbidden - User banned");
    } else {
      print("❌ Error ${response.statusCode}: ${response.body}");
      try {
        var errorData = jsonDecode(response.body);
        var errorMessage =
            errorData['message'] ?? errorData['title'] ?? errorData.toString();
        throw Exception("API Error (${response.statusCode}): $errorMessage");
      } catch (e) {
        if (e is Exception && e.toString().contains('API Error')) {
          rethrow;
        }
        throw Exception("API Error (${response.statusCode}): ${response.body}");
      }
    }
  }

  // ⭐ Handling bana
  void _handleBanRedirect(Response response) {
    try {
      final data = jsonDecode(response.body);
      final message = data['message']?.toString().toLowerCase() ?? '';

      if (message.contains('banovan') || message.contains('banned')) {
        print('🚫 User is banned! Details: ${data['reason']}');
        // Note: Ban handling should be done at the UI level when user tries to login
        // or through a proper error state management system
        // Direct navigation from a provider is not compatible with GoRouter
      }
    } catch (e) {
      print('Error handling ban redirect: $e');
    }
  }

  Map<String, String> createHeaders() {
    String token = AuthProvider.token ?? "";

    print("Creating headers with JWT Bearer token");
    print(
      "Token is ${token.isNotEmpty ? 'set (${token.length} chars)' : 'EMPTY'}",
    );

    var headers = {"Content-Type": "application/json"};

    if (token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
      print(
        "Authorization header: Bearer ${token.substring(0, token.length > 20 ? 20 : token.length)}...",
      );
    }

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
