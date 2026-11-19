import 'auth_response_exception.dart';

class AuthOperationResponseModel {
  const AuthOperationResponseModel({required this.message});

  final String? message;

  factory AuthOperationResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['successfully'] != true) {
      throw const AuthResponseException();
    }
    return AuthOperationResponseModel(message: json['message'] as String?);
  }
}
