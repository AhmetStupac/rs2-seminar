class AppConfig {
  static const String _defaultServerUrl = 'http://10.0.2.2:7093';
  static const String _legacyBaseUrl = String.fromEnvironment(
    'baseUrl',
    defaultValue: '',
  );
  static const String _serverUrlOverride = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: '',
  );

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

  static String get signalRBaseUrl => serverUrl;

  static String get blobStorageBaseUrl => '$serverUrl/';

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
