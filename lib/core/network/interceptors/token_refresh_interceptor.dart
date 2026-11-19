import 'package:dio/dio.dart';

import '../token_refresh_handler.dart';
import 'auth_interceptor.dart';

final class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor({
    required Dio dio,
    required TokenRefreshHandler handler,
  }) : _dio = dio,
       _handler = handler;

  static const _retriedExtraKey = 'authRetried';
  static const skipRefreshExtraKey = 'skipTokenRefresh';

  final Dio _dio;
  final TokenRefreshHandler _handler;
  Future<bool>? _refreshInProgress;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[AuthInterceptor.requiresAuthExtraKey] != true ||
        options.extra[skipRefreshExtraKey] == true) {
      handler.next(options);
      return;
    }

    try {
      if (!await _runOnce(_handler.ensureValidAccessToken)) {
        await _handler.onSessionExpired();
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response<dynamic>(
              requestOptions: options,
              statusCode: 401,
            ),
          ),
        );
        return;
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

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    if (options.extra[AuthInterceptor.requiresAuthExtraKey] != true ||
        options.extra[skipRefreshExtraKey] == true ||
        err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }
    if (options.extra[_retriedExtraKey] == true) {
      await _handler.onSessionExpired();
      handler.next(err);
      return;
    }

    try {
      final authorization = options.headers['Authorization']?.toString();
      if (!await _runOnce(
        () => _handler.refreshAccessToken(accessTokenUsed: authorization),
      )) {
        await _handler.onSessionExpired();
        handler.next(err);
        return;
      }

      final headers = Map<String, dynamic>.from(options.headers)
        ..remove('Authorization');
      final retryOptions = options.copyWith(
        headers: headers,
        extra: {...options.extra, _retriedExtraKey: true},
      );
      final response = await _dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on Object catch (error, stackTrace) {
      handler.reject(
        error is DioException
            ? error
            : DioException(
                requestOptions: options,
                error: error,
                stackTrace: stackTrace,
              ),
      );
    }
  }

  Future<bool> _runOnce(Future<bool> Function() action) {
    final inProgress = _refreshInProgress;
    if (inProgress != null) return inProgress;

    late final Future<bool> refresh;
    refresh = action().whenComplete(() {
      if (identical(_refreshInProgress, refresh)) {
        _refreshInProgress = null;
      }
    });
    _refreshInProgress = refresh;
    return refresh;
  }
}
