import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../config/environment.dart';
import '../security/secure_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/safe_log_interceptor.dart';
import 'interceptors/token_refresh_interceptor.dart';
import 'token_refresh_handler.dart';

final class ApiClient {
  ApiClient({required AppConfig config, required SecureStorage secureStorage})
    : dio = Dio(
        BaseOptions(
          baseUrl: config.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          headers: const {
            Headers.contentTypeHeader: Headers.jsonContentType,
            Headers.acceptHeader: Headers.jsonContentType,
          },
        ),
      ) {
    dio.interceptors.add(AuthInterceptor(secureStorage));
    if (config.environment != Environment.production) {
      dio.interceptors.add(SafeLogInterceptor());
    }
  }

  final Dio dio;

  void installTokenRefreshHandler(TokenRefreshHandler handler) {
    if (dio.interceptors.any(
      (interceptor) => interceptor is TokenRefreshInterceptor,
    )) {
      throw StateError('A token refresh handler is already installed.');
    }
    dio.interceptors.insert(
      0,
      TokenRefreshInterceptor(dio: dio, handler: handler),
    );
  }

  void close({bool force = false}) {
    dio.close(force: force);
  }
}
