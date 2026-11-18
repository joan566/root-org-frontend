import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:savings_api_frontend/core/errors/api_exception.dart';
import 'package:savings_api_frontend/core/networking/api_config.dart';

class RoleApi {
  final String baseUrl = "${ApiConfig.baseUrl}/roles";

  Uri _uri(String path, Map<String, String>? queryParameters) {
    final url = path.isEmpty ? baseUrl : '$baseUrl/$path';
    return Uri.parse(url).replace(queryParameters: queryParameters);
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

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? queryParameters,
    required String token,
  }) async {
    final response = await http.get(
      _uri(path, queryParameters),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> listRoles({
    required int tenantId,
    required String token,
  }) {
    return _get('', queryParameters: {'tenantId': '$tenantId'}, token: token);
  }
}
