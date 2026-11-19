class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.102:8080/api/v1',
  );

  static String get baseUrl =>
      _configuredBaseUrl.replaceFirst(RegExp(r'/+$'), '');
}
