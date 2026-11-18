import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:savings_api_frontend/core/errors/api_exception.dart';
import 'package:savings_api_frontend/core/networking/api_config.dart';

class UserApi {
  final String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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

  Future<Map<String, dynamic>> _get(
    String endpoint, {
    Map<String, String>? queryParameters,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint')
        .replace(queryParameters: queryParameters);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.body.isEmpty) {
      throw Exception("Respuesta vacía del servidor");
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception("Respuesta inválida: ${response.body}");
    }

    if (response.statusCode == 200) {
      return decoded;
    }

    throw ApiException(
      statusCode: response.statusCode,
      errorCode: decoded["error"] ?? "UNKNOWN",
      message: decoded["message"] ?? "Error inesperado",
    );
  }

  Future<Map<String, dynamic>> getProfile({
    required int userId,
    required String token,
  }) async {
    return await _get(
      "users/profile",
      queryParameters: {"id": userId.toString()},
      token: token,
    );
  }

  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String name,
    required String lastName,
    required String document,
    required String phoneNumber,
    required String dateOfBirth,
    required String gender,
    required String token,
  }) async {
    return await _post("users/update-profile", {
      "userId": userId,
      "name": name,
      "lastName": lastName,
      "document": document,
      "phoneNumber": phoneNumber,
      "dateOfBirth": dateOfBirth,
      "gender": gender,
    }, token);
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
    required String token,
  }) async {
    return await _post("auth/users/change-password", {
      "oldPassword": oldPassword,
      "newPassword": newPassword,
      "confirmPassword": confirmPassword,
    }, token);
  }
}
