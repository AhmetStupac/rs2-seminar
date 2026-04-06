import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:personaltrainer_desktop/config/app_config.dart';
import 'package:personaltrainer_desktop/models/search_result.dart';
import 'package:personaltrainer_desktop/providers/auth_provider.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  String _endpoint = "";

  static String get baseUrl => AppConfig.apiBaseUrl;

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


    var response = await http.get(uri, headers: headers);


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

  Future<T> getById(int id) async {
    var url = "$baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);


    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> insert(dynamic request) async {
    var url = "$baseUrl$_endpoint";
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
    var url = "$baseUrl$_endpoint/$id";
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

  Future<void> delete(int id) async {
    var url = "$baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception("Unknown error");
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  String _extractErrorMessage(String body) {
    if (body.isEmpty) return 'An error occurred.';

    // Try JSON first
    try {
      final data = jsonDecode(body);
      if (data is Map) {
        // ASP.NET Core ModelState: { "errors": { "Field": ["msg"] } }
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          for (final entry in errors.entries) {
            final msgs = entry.value;
            if (msgs is List && msgs.isNotEmpty) return msgs.first.toString();
          }
        }
        // FluentValidation: { "errors": [ { "errorMessage": "..." } ] }
        if (data['errors'] is List) {
          final errors = data['errors'] as List;
          if (errors.isNotEmpty) {
            final first = errors.first;
            if (first is Map) {
              final msg =
                  first['errorMessage'] ??
                  first['message'] ??
                  first['description'];
              if (msg != null) return msg.toString();
            }
          }
        }
        final msg = data['message'] ?? data['title'] ?? data['detail'];
        if (msg != null && msg.toString().isNotEmpty) return msg.toString();
      }
    } catch (_) {}

    // Plain text stack trace: take first line, strip the exception type prefix
    // e.g. "System.ArgumentException: Validation failed: Description is required."
    final firstLine = body.split('\n').first.trim();
    final colonIdx = firstLine.indexOf(': ');
    if (colonIdx != -1) return firstLine.substring(colonIdx + 2);

    return 'An error occurred.';
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else if (response.statusCode == 403) {
      // â­ Proveri da li je ban
      _handleBanRedirect(response);
      throw Exception("Access forbidden - User banned");
    } else {
      throw Exception(_extractErrorMessage(response.body));
    }
  }

  // â­ Handling bana
  void _handleBanRedirect(Response response) {
    try {
      final data = jsonDecode(response.body);
      final message = data['message']?.toString().toLowerCase() ?? '';

      if (message.contains('banovan') || message.contains('banned')) {
        // Note: Ban handling should be done at the UI level when user tries to login
        // or through a proper error state management system
        // Direct navigation from a provider is not compatible with GoRouter
      }
    } catch (e) {
    }
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

