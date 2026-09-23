import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:savings_api_frontend/core/errors/api_exception.dart';

class OrganizationUnitApi {
  final String baseUrl = "http://192.168.0.104:8080/organization-units";

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

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> data,
    String token, {
    Map<String, String>? queryParameters,
  }) async {
    final response = await http.post(
      _uri(path, queryParameters),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> data, String token) async {
    final response = await http.put(
      _uri(path, null),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> _delete(
    String path, {
    Map<String, String>? queryParameters,
    required String token,
  }) async {
    final response = await http.delete(
      _uri(path, queryParameters),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> listUnits({required int tenantId, required String token}) {
    return _get('', queryParameters: {'tenantId': '$tenantId'}, token: token);
  }

  Future<Map<String, dynamic>> createUnit({
    required int tenantId,
    required String name,
    required String description,
    int? parentUnitId,
    required String token,
  }) {
    return _post('', {
      'tenantId': tenantId,
      'name': name,
      'description': description,
      'parentUnitId': parentUnitId,
    }, token);
  }

  Future<Map<String, dynamic>> updateUnit({
    required int id,
    required int tenantId,
    required String name,
    required String description,
    int? parentUnitId,
    String? status,
    required String token,
  }) {
    return _put('$id', {
      'tenantId': tenantId,
      'name': name,
      'description': description,
      'parentUnitId': parentUnitId,
      'status': status,
    }, token);
  }

  Future<Map<String, dynamic>> deleteUnit({required int id, required int tenantId, required String token}) {
    return _delete('$id', queryParameters: {'tenantId': '$tenantId'}, token: token);
  }

  Future<Map<String, dynamic>> assignMember({
    required int id,
    required int tenantId,
    required int userId,
    required String token,
  }) {
    return _post('$id/members', {'tenantId': tenantId, 'userId': userId}, token);
  }

  Future<Map<String, dynamic>> removeMember({
    required int id,
    required int tenantId,
    required int userId,
    required String token,
  }) {
    return _delete('$id/members/$userId', queryParameters: {'tenantId': '$tenantId'}, token: token);
  }

  Future<Map<String, dynamic>> assignManager({
    required int id,
    required int tenantId,
    required int userId,
    required int roleId,
    required String token,
  }) {
    return _post('$id/manager', {'tenantId': tenantId, 'userId': userId, 'roleId': roleId}, token);
  }

  Future<Map<String, dynamic>> transferManager({
    required int id,
    required int tenantId,
    required int newUserId,
    required String token,
  }) {
    return _put('$id/manager', {'tenantId': tenantId, 'newUserId': newUserId}, token);
  }

  Future<Map<String, dynamic>> removeManager({required int id, required int tenantId, required String token}) {
    return _delete('$id/manager', queryParameters: {'tenantId': '$tenantId'}, token: token);
  }

  /// `manager` en la respuesta es `null` cuando la unidad no tiene encargado
  /// vigente -- no es un error (ver ADR-021).
  Future<Map<String, dynamic>> getManager({required int id, required int tenantId, required String token}) {
    return _get('$id/manager', queryParameters: {'tenantId': '$tenantId'}, token: token);
  }

  /// El usuario se resuelve del JWT -- sin body, sin `tenantId`.
  Future<Map<String, dynamic>> requestToJoinUnit({required int id, required String token}) {
    return _post('$id/join-requests', {}, token);
  }

  /// Sin `id` de unidad en la ruta -- el backend valida que la solicitud
  /// pertenezca al usuario autenticado (mismo patrón que
  /// `TenantApi.cancelJoinRequest`).
  Future<Map<String, dynamic>> cancelUnitJoinRequest({required int requestId, required String token}) {
    return _post('join-requests/$requestId/cancel', {}, token);
  }

  Future<Map<String, dynamic>> getMyUnitJoinRequests({required String token}) {
    return _get('join-requests/mine', token: token);
  }

  Future<Map<String, dynamic>> assignMemberRole({
    required int id,
    required int tenantId,
    required int userId,
    required int roleId,
    required String token,
  }) {
    return _post('$id/members/$userId/role', {'tenantId': tenantId, 'roleId': roleId}, token);
  }

  Future<Map<String, dynamic>> removeMemberRole({
    required int id,
    required int tenantId,
    required int userId,
    required int roleId,
    required String token,
  }) {
    return _delete(
      '$id/members/$userId/role',
      queryParameters: {'tenantId': '$tenantId', 'roleId': '$roleId'},
      token: token,
    );
  }

  Future<Map<String, dynamic>> listUnitJoinRequests({
    required int id,
    required int tenantId,
    required String token,
  }) {
    return _get('$id/join-requests', queryParameters: {'tenantId': '$tenantId'}, token: token);
  }

  Future<Map<String, dynamic>> approveUnitJoinRequest({
    required int id,
    required int requestId,
    required int tenantId,
    required String token,
  }) {
    return _post('$id/join-requests/$requestId/approve', {}, token, queryParameters: {'tenantId': '$tenantId'});
  }

  Future<Map<String, dynamic>> rejectUnitJoinRequest({
    required int id,
    required int requestId,
    required int tenantId,
    required String token,
  }) {
    return _post('$id/join-requests/$requestId/reject', {}, token, queryParameters: {'tenantId': '$tenantId'});
  }
}
