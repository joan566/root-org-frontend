import 'package:RootOrg/core/config/app_config.dart';
import 'package:RootOrg/core/config/environment.dart';
import 'package:RootOrg/core/network/api_client.dart';
import 'package:RootOrg/core/network/interceptors/auth_interceptor.dart';
import 'package:RootOrg/core/network/interceptors/safe_log_interceptor.dart';
import 'package:RootOrg/core/security/secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('configures shared Dio options and development interceptors', () {
    final client = ApiClient(
      config: AppConfig(
        environment: Environment.development,
        apiBaseUrl: 'https://api.example.com/v1',
      ),
      secureStorage: SecureStorage(),
    );
    addTearDown(client.close);

    expect(client.dio.options.baseUrl, 'https://api.example.com/v1');
    expect(client.dio.options.connectTimeout, const Duration(seconds: 15));
    expect(client.dio.interceptors, contains(isA<AuthInterceptor>()));
    expect(client.dio.interceptors, contains(isA<SafeLogInterceptor>()));
  });

  test('does not install request logging in production', () {
    final client = ApiClient(
      config: AppConfig(
        environment: Environment.production,
        apiBaseUrl: 'https://api.example.com',
      ),
      secureStorage: SecureStorage(),
    );
    addTearDown(client.close);

    expect(client.dio.interceptors, contains(isA<AuthInterceptor>()));
    expect(client.dio.interceptors, isNot(contains(isA<SafeLogInterceptor>())));
  });
}
