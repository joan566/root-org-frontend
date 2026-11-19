import 'package:dio/dio.dart';

import '../../data/models/auth_response_exception.dart';

abstract final class AuthErrorMessage {
  static String from(
    Object error, {
    required String fallback,
    String? invalidCredentialsMessage,
  }) {
    if (error is DioException) {
      return switch (error.response?.statusCode) {
        400 => 'Revisa los datos ingresados e inténtalo nuevamente.',
        401 => invalidCredentialsMessage ?? 'No se pudo validar la solicitud.',
        403 => 'No tienes permiso para realizar esta acción.',
        final int status when status >= 500 =>
          'El servicio no está disponible. Inténtalo más tarde.',
        _
            when error.type == DioExceptionType.connectionTimeout ||
                error.type == DioExceptionType.receiveTimeout ||
                error.type == DioExceptionType.sendTimeout ||
                error.type == DioExceptionType.connectionError =>
          'No se pudo conectar. Verifica tu conexión.',
        _ => fallback,
      };
    }
    if (error is AuthResponseException || error is FormatException) {
      return 'El servidor devolvió una respuesta inesperada.';
    }
    return fallback;
  }
}
