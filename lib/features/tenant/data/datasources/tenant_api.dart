import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:savings_api_frontend/core/errors/api_exception.dart';

class TenantApi {
  final String baseUrl = "http://192.168.0.104:8080/tenant";

  // Método privado para realizar solicitudes POST
  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> data, String token) async {
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

  Future<Map<String, dynamic>> createTenantWithOwner({
      required String name,
      required String description,
      required int userId,
      required String token
  }) {
    return _post("create-with-owner", {
      "name": name,
      "description": description,
      "userId": userId
    }, token);
  }

  Future<Map<String, dynamic>> jointTenant({
    required int userId, required String tenantCode, required String token
  }) {
    return _post("join-tenant", {
      "userId": userId,
      "tenantCode": tenantCode
    },
    token);
  }
}