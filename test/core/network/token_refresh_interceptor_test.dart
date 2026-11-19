import 'dart:convert';
import 'dart:typed_data';

import 'package:RootOrg/core/network/interceptors/auth_interceptor.dart';
import 'package:RootOrg/core/network/interceptors/token_refresh_interceptor.dart';
import 'package:RootOrg/core/network/token_refresh_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('refreshes once and retries an authenticated request once', () async {
    var protectedRequests = 0;
    final adapter = _CallbackAdapter((options) async {
      if (options.path == '/protected') {
        protectedRequests++;
        if (protectedRequests == 1) {
          return _jsonResponse({'message': 'expired'}, 401);
        }
      }
      return _jsonResponse({'ok': true}, 200);
    });
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
      ..httpClientAdapter = adapter;
    final refreshHandler = _FakeRefreshHandler();
    dio.interceptors.addAll([
      TokenRefreshInterceptor(dio: dio, handler: refreshHandler),
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer fresh-token';
          handler.next(options);
        },
      ),
    ]);
    addTearDown(dio.close);

    final response = await dio.get<Object?>(
      '/protected',
      options: Options(extra: {AuthInterceptor.requiresAuthExtraKey: true}),
    );

    expect(response.statusCode, 200);
    expect(protectedRequests, 2);
    expect(refreshHandler.refreshCalls, 1);
    expect(refreshHandler.expiredCalls, 0);
  });

  test('does not refresh public requests', () async {
    var requests = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
      ..httpClientAdapter = _CallbackAdapter((_) async {
        requests++;
        return _jsonResponse({'ok': true}, 200);
      });
    final refreshHandler = _FakeRefreshHandler();
    dio.interceptors.add(
      TokenRefreshInterceptor(dio: dio, handler: refreshHandler),
    );
    addTearDown(dio.close);

    await dio.post<Object?>('/api/v1/auth/login');

    expect(requests, 1);
    expect(refreshHandler.ensureCalls, 0);
    expect(refreshHandler.refreshCalls, 0);
  });

  test(
    'expires the local session if a retried request is still unauthorized',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'))
        ..httpClientAdapter = _CallbackAdapter(
          (_) async => _jsonResponse({'message': 'unauthorized'}, 401),
        );
      final refreshHandler = _FakeRefreshHandler();
      dio.interceptors.add(
        TokenRefreshInterceptor(dio: dio, handler: refreshHandler),
      );
      addTearDown(dio.close);

      await expectLater(
        dio.get<Object?>(
          '/protected',
          options: Options(extra: {AuthInterceptor.requiresAuthExtraKey: true}),
        ),
        throwsA(isA<DioException>()),
      );

      expect(refreshHandler.refreshCalls, 1);
      expect(refreshHandler.expiredCalls, 1);
    },
  );
}

ResponseBody _jsonResponse(Map<String, Object?> value, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(value),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

class _CallbackAdapter implements HttpClientAdapter {
  _CallbackAdapter(this._onFetch);

  final Future<ResponseBody> Function(RequestOptions) _onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}

class _FakeRefreshHandler implements TokenRefreshHandler {
  int ensureCalls = 0;
  int refreshCalls = 0;
  int expiredCalls = 0;

  @override
  Future<bool> ensureValidAccessToken() async {
    ensureCalls++;
    return true;
  }

  @override
  Future<bool> refreshAccessToken({String? accessTokenUsed}) async {
    refreshCalls++;
    return true;
  }

  @override
  Future<void> onSessionExpired() async {
    expiredCalls++;
  }
}
