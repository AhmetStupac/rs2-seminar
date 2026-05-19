class AppConfig {
  static const String _defaultServerUrl = 'https://10.0.2.2:7093';
  static const String _defaultSignalRServerUrl = 'http://10.0.2.2:7094';

  static const String _legacyBaseUrl = String.fromEnvironment(
    'baseUrl',
    defaultValue: '',
  );
  static const String _serverUrlOverride = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: '',
  );
  static const String _signalRUrlOverride = String.fromEnvironment(
    'SIGNALR_URL',
    defaultValue: '',
  );

  /// HTTPS root for REST API (e.g. https://10.0.2.2:7093).
  static String get serverUrl {
    if (_serverUrlOverride.isNotEmpty) {
      return _trimTrailingSlash(_serverUrlOverride);
    }

    if (_legacyBaseUrl.isNotEmpty) {
      final legacy = _trimTrailingSlash(_legacyBaseUrl);
      if (legacy.endsWith('/api')) {
        return legacy.substring(0, legacy.length - 4);
      }
      return legacy;
    }

    return _defaultServerUrl;
  }

  static String get apiBaseUrl {
    if (_legacyBaseUrl.isNotEmpty) {
      return _ensureTrailingSlash(_legacyBaseUrl);
    }

    return '$serverUrl/api/';
  }

  /// HTTP root for SignalR hubs (e.g. http://10.0.2.2:7094).
  /// Backend dev: API on HTTPS :7093, SignalR on HTTP :7094.
  static String get signalRBaseUrl {
    if (_signalRUrlOverride.isNotEmpty) {
      return _trimTrailingSlash(_signalRUrlOverride);
    }

    if (_serverUrlOverride.isNotEmpty || _legacyBaseUrl.isNotEmpty) {
      return _toSignalRUrl(serverUrl);
    }

    return _defaultSignalRServerUrl;
  }

  static String get blobStorageBaseUrl => '$serverUrl/';

  /// Maps API host to SignalR: same host, http scheme, port 7093 → 7094.
  static String _toSignalRUrl(String apiServerUrl) {
    final uri = Uri.parse(apiServerUrl);
    final port = uri.hasPort && uri.port == 7093 ? 7094 : uri.port;
    return Uri(
      scheme: 'http',
      host: uri.host,
      port: port,
    ).toString();
  }

  static String _trimTrailingSlash(String value) {
    if (value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }

  static String _ensureTrailingSlash(String value) {
    if (value.endsWith('/')) {
      return value;
    }
    return '$value/';
  }
}
