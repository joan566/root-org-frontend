import 'environment.dart';

final class AppConfig {
  static const _environmentName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );
  static const _configuredApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.102:8080',
  );

  final Environment environment;
  final String apiBaseUrl;

  AppConfig({required this.environment, required String apiBaseUrl})
    : apiBaseUrl = _normalizeAndValidateApiBaseUrl(apiBaseUrl);

  factory AppConfig.fromEnvironment() {
    if (_configuredApiBaseUrl.trim().isEmpty) {
      throw StateError(
        'API_BASE_URL is required. Provide it with '
        '--dart-define=API_BASE_URL=https://your-api.example.com.',
      );
    }

    return AppConfig(
      environment: Environment.parse(_environmentName),
      apiBaseUrl: _configuredApiBaseUrl,
    );
  }

  static String _normalizeAndValidateApiBaseUrl(String value) {
    final trimmedValue = value.trim();
    final uri = Uri.tryParse(trimmedValue);

    if (trimmedValue.isEmpty ||
        uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw FormatException(
        'Invalid API_BASE_URL "$value". Expected an absolute HTTP or HTTPS '
        'URL without credentials, query, or fragment.',
      );
    }

    final normalizedPath = uri.path.replaceFirst(RegExp(r'/+$'), '');
    return uri.replace(path: normalizedPath).toString();
  }
}
