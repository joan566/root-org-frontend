import 'dart:developer' as developer;

import 'package:dio/dio.dart';

final class SafeLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log('Request: ${options.method}', name: 'app.network');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    developer.log('Response: ${response.statusCode}', name: 'app.network');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log('Request failed: ${err.type.name}', name: 'app.network');
    handler.next(err);
  }
}
