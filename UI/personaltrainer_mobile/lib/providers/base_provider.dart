import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:personaltrainer_mobile/config/app_config.dart';
import 'package:personaltrainer_mobile/models/search_result.dart';
import 'package:personaltrainer_mobile/providers/auth_provider.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  String _endpoint = "";
  static http.Client? _client;
  static String? _lastRequestSummary;

  static String get baseUrl => AppConfig.apiBaseUrl;
  static String? get lastRequestSummary => _lastRequestSummary;

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
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = "$baseUrl$_endpoint";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();
    _trackRequest('GET', uri);

    var response = await client.get(uri, headers: headers);

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
    var url = "$baseUrl$_endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    _trackRequest('POST', uri);

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
    var url = "$baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    _trackRequest('PUT', uri);

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
    var url = "$baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    _trackRequest('DELETE', uri);

    var response = await client.delete(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception("Unknown error");
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  void _trackRequest(String method, Uri uri) {
    _lastRequestSummary = '$method ${uri.path}';
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else if (response.statusCode == 403) {
      // ⭐ Proveri da li je ban
      _handleBanRedirect(response);
      throw Exception("Access forbidden - User banned");
    } else {
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
        // Note: Ban handling should be done at the UI level when user tries to login
        // or through a proper error state management system
        // Direct navigation from a provider is not compatible with GoRouter
      }
    } catch (e) {}
  }

  Map<String, String> createHeaders() {
    String token = AuthProvider.token ?? "";

    var headers = {"Content-Type": "application/json"};

    if (token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
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
