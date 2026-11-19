abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class ApiException extends AppException {
  const ApiException({required this.statusCode, this.errorCode})
    : super('The API request failed.');

  final int statusCode;
  final String? errorCode;
}

final class NetworkException extends AppException {
  const NetworkException() : super('The network request failed.');
}

final class StorageException extends AppException {
  const StorageException() : super('A storage operation failed.');
}
