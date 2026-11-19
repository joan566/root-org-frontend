import 'package:dio/dio.dart';

import 'exceptions/app_exception.dart';
import 'failures/failure.dart';

abstract final class ErrorHandler {
  static Failure from(Object error) {
    if (error is DioException) {
      return _fromDioException(error);
    }
    if (error is ApiException) {
      return _fromStatusCode(error.statusCode);
    }
    if (error is NetworkException) {
      return const NetworkFailure();
    }
    if (error is StorageException) {
      return const StorageFailure();
    }
    return const UnexpectedFailure();
  }

  static Failure _fromDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => const TimeoutFailure(),
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate => const NetworkFailure(),
      DioExceptionType.cancel => const RequestCancelledFailure(),
      DioExceptionType.badResponse => _fromStatusCode(
        error.response?.statusCode,
      ),
      DioExceptionType.unknown => const UnexpectedFailure(),
    };
  }

  static Failure _fromStatusCode(int? statusCode) {
    return switch (statusCode) {
      401 => const UnauthorizedFailure(),
      403 => const ForbiddenFailure(),
      404 => const NotFoundFailure(),
      final int code when code >= 500 => const ServerFailure(),
      _ => const RequestFailure(),
    };
  }
}
