class ApiException implements Exception {
  final int statusCode;
  final String errorCode;
  final String message;

  ApiException({
    required this.statusCode,
    required this.errorCode,
    required this.message,
  });

  @override
  String toString() => message;
}
