import 'package:dio/dio.dart';

import '../../security/secure_storage.dart';
import '../../storage/storage_keys.dart';

final class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  static const requiresAuthExtraKey = 'requiresAuth';

  final SecureStorage _secureStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[requiresAuthExtraKey] != true ||
        options.headers.containsKey('Authorization')) {
      handler.next(options);
      return;
    }

    try {
      final token = await _secureStorage.read(StorageKeys.accessToken);
      if (token != null && token.trim().isNotEmpty) {
        options.headers['Authorization'] = 'Bearer ${token.trim()}';
      }
      handler.next(options);
    } on Object catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
