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

  Future<Map<String, dynamic>> _put(String endpoint, Map<String, dynamic> data, String token) async {
    final response = await http.put(
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

    if (response.statusCode == 200) {
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
    final uri = Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParameters);

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

  Future<Map<String, dynamic>> getTenantUsers({
    required int tenantId,
    required String token,
  }) {
    return _get('$tenantId/users', token: token);
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

  /// Crea una solicitud de ingreso (ya no una membresía directa -- ver
  /// docs/01-features/organizaciones.md). El código solo identifica la
  /// organización; la relación `UserTenant` se crea únicamente cuando un
  /// admin aprueba la solicitud (`approveJoinRequest`).
  Future<Map<String, dynamic>> requestToJoinTenant({
    required String tenantCode, required String token
  }) {
    return _post("join-tenant", {
      "tenantCode": tenantCode
    },
    token);
  }

  Future<Map<String, dynamic>> getPendingJoinRequests({
    required int tenantId, required String token
  }) {
    return _get('$tenantId/join-requests', token: token);
  }

  Future<Map<String, dynamic>> approveJoinRequest({
    required int tenantId, required int requestId, required String token
  }) {
    return _post('$tenantId/join-requests/$requestId/approve', {}, token);
  }

  Future<Map<String, dynamic>> rejectJoinRequest({
    required int tenantId, required int requestId, required String token
  }) {
    return _post('$tenantId/join-requests/$requestId/reject', {}, token);
  }

  /// Sin `tenantId` en la ruta -- el backend valida que la solicitud
  /// pertenezca al usuario autenticado.
  Future<Map<String, dynamic>> cancelJoinRequest({
    required int requestId, required String token
  }) {
    return _post('join-requests/$requestId/cancel', {}, token);
  }

  Future<Map<String, dynamic>> getMyJoinRequests({required String token}) {
    return _get('join-requests/mine', token: token);
  }

  /// Actualiza nombre/descripción de un tenant existente (código y estado no
  /// se tocan desde este endpoint). Permiso requerido en backend:
  /// `core.tenant.update`.
  Future<Map<String, dynamic>> updateTenant({
    required int tenantId,
    required String name,
    required String description,
    required String token,
  }) {
    return _put('$tenantId', {
      "name": name,
      "description": description,
    }, token);
  }
}