import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static final String apiBaseUrl = _normalizeApiBaseUrl(
    const String.fromEnvironment('baseUrl', defaultValue: ''),
  );

  static final String serverBaseUrl = _deriveServerBaseUrl(apiBaseUrl);

  static Uri apiUri(String path, {Map<String, dynamic>? queryParameters}) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse(
      '$apiBaseUrl$normalizedPath',
    ).replace(queryParameters: _normalizeQueryParams(queryParameters));
  }

  static Uri hubUri(String hubPath, {Map<String, dynamic>? queryParameters}) {
    final normalizedPath = hubPath.startsWith('/')
        ? hubPath.substring(1)
        : hubPath;

    return Uri.parse(
      '$serverBaseUrl/hubs/$normalizedPath',
    ).replace(queryParameters: _normalizeQueryParams(queryParameters));
  }

  static Map<String, String>? _normalizeQueryParams(
    Map<String, dynamic>? queryParameters,
  ) {
    if (queryParameters == null || queryParameters.isEmpty) {
      return null;
    }

    return queryParameters.map((key, value) => MapEntry(key, value.toString()));
  }

  static String _normalizeApiBaseUrl(String configuredBaseUrl) {
    final trimmed = configuredBaseUrl.trim();

    if (trimmed.isEmpty) {
      return '${_defaultServerBaseUrl()}/api/';
    }

    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }

  static String _deriveServerBaseUrl(String apiUrl) {
    var normalized = apiUrl;

    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    if (normalized.toLowerCase().endsWith('/api')) {
      normalized = normalized.substring(0, normalized.length - 4);
    }

    return normalized;
  }

  static String _defaultServerBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:7093';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:7093';
    }

    return 'http://localhost:7093';
  }
}
