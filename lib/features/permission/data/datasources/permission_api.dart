import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:savings_api_frontend/core/errors/api_exception.dart';

class PermissionApi {
  final String baseUrl = "http://192.168.0.104:8080/me/permissions";

  Uri _uri(Map<String, String> queryParameters) {
    return Uri.parse(baseUrl).replace(queryParameters: queryParameters);
  }

  Map<String, dynamic> _decode(http.Response response) {
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

  /// Si `organizationUnitId` es null, el backend solo devuelve los permisos
  /// a nivel tenant -- ignora por completo cualquier rol asignado a nivel de
  /// unidad (ver ADR-021).
  Future<Map<String, dynamic>> getMyPermissions({
    required int tenantId,
    int? organizationUnitId,
    required String token,
  }) async {
    final queryParameters = {
      'tenantId': '$tenantId',
      if (organizationUnitId != null) 'organizationUnitId': '$organizationUnitId',
    };

    final response = await http.get(
      _uri(queryParameters),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return _decode(response);
  }
}
