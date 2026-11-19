import 'package:flutter_test/flutter_test.dart';

import 'package:RootOrg/core/config/app_config.dart';
import 'package:RootOrg/core/config/environment.dart';

void main() {
  group('Environment.parse', () {
    test('parses supported environment names', () {
      expect(Environment.parse('development'), Environment.development);
      expect(Environment.parse('STAGING'), Environment.staging);
      expect(Environment.parse(' production '), Environment.production);
    });

    test('rejects unknown environment names', () {
      expect(() => Environment.parse('local'), throwsFormatException);
    });
  });

  group('AppConfig', () {
    test('normalizes whitespace and trailing slashes in API base URL', () {
      final config = AppConfig(
        environment: Environment.development,
        apiBaseUrl: ' https://api.example.com/v1/// ',
      );

      expect(config.apiBaseUrl, 'https://api.example.com/v1');
    });

    test('rejects URLs that are not absolute HTTP or HTTPS base URLs', () {
      expect(
        () => AppConfig(
          environment: Environment.development,
          apiBaseUrl: 'api.example.com',
        ),
        throwsFormatException,
      );
      expect(
        () => AppConfig(
          environment: Environment.development,
          apiBaseUrl: 'ftp://api.example.com',
        ),
        throwsFormatException,
      );
      expect(
        () => AppConfig(
          environment: Environment.development,
          apiBaseUrl: 'https://api.example.com?token=secret',
        ),
        throwsFormatException,
      );
    });
  });
}
