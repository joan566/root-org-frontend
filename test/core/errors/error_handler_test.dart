import 'package:RootOrg/core/errors/error_handler.dart';
import 'package:RootOrg/core/errors/exceptions/app_exception.dart';
import 'package:RootOrg/core/errors/failures/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorHandler.from', () {
    test('maps connection timeouts to a timeout failure', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(ErrorHandler.from(error), isA<TimeoutFailure>());
    });

    test('maps unauthorized responses to an authentication failure', () {
      final requestOptions = RequestOptions(path: '/');
      final error = DioException(
        requestOptions: requestOptions,
        response: Response<void>(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      expect(ErrorHandler.from(error), isA<UnauthorizedFailure>());
    });

    test('maps API server errors without exposing backend messages', () {
      final failure = ErrorHandler.from(const ApiException(statusCode: 503));

      expect(failure, isA<ServerFailure>());
      expect(failure.message, isNot(contains('503')));
    });

    test('maps unknown errors to an unexpected failure', () {
      expect(
        ErrorHandler.from(StateError('internal detail')),
        isA<UnexpectedFailure>(),
      );
    });
  });
}
