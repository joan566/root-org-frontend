import 'dart:developer' as developer;

import 'package:dio/dio.dart';

final class SafeLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      'Request: ${options.method} ${options.uri.path}',
      name: 'app.network',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    developer.log(
      'Response: ${response.statusCode} ${response.requestOptions.uri.path}',
      name: 'app.network',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      'Request failed: ${err.requestOptions.method} '
      '${err.requestOptions.uri.path} (${err.type.name})',
      name: 'app.network',
    );
    handler.next(err);
  }
}
