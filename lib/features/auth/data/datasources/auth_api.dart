import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:savings_api_frontend/core/errors/api_exception.dart';
import 'package:savings_api_frontend/core/networking/api_config.dart';

class AuthApi {
  final String baseUrl = ApiConfig.baseUrl;

  // Método privado para realizar solicitudes POST
  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.body.isEmpty) {
      throw Exception("Respuesta vacía del servidor");
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception("Respuesta inválida: ${response.body}");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return decoded;
    }

    throw ApiException(
      statusCode: response.statusCode,
      errorCode: decoded["error"] ?? "UNKNOWN",
      message: decoded["message"] ?? "Error inesperado",
    );
  }

  // Método para iniciar sesión
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return _post("auth/login", {"email": email, "password": password});
  }

  // Método para registrarse
  Future<Map<String, dynamic>> register({
    required String name,
    required String phoneNumber,
    required String email,
    required String password,
  }) {
    return _post("auth/users/create", {
      "name": name,
      "phoneNumber": phoneNumber,
      "email": email,
      "password": password,
    });
  }

  // Métodos para recuperación de contraseña
  Future<Map<String, dynamic>> forgotPassword(String email) {
    return _post("auth/forgot-password", {"email": email});
  }

  Future<Map<String, dynamic>> verifyCode(String email, String code) {
    return _post("auth/verify-code", {"email": email, "code": code});
  }

  Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _post("auth/reset-password", {
      "resetToken": resetToken,
      "newPassword": newPassword,
      "confirmPassword": confirmPassword,
    });
  }
}
