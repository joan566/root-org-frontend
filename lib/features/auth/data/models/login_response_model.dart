import 'package:savings_api_frontend/features/auth/data/models/user_model.dart';

class LoginResponseModel {
  final bool successfully;
  final String message;
  final String token;
  final bool hasTenant;
  final UserModel user;

  LoginResponseModel({
    required this.successfully,
    required this.message,
    required this.token,
    required this.hasTenant,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      successfully: json['successfully'],
      message: json['message'],
      token: json['token'],
      hasTenant: json['hasTenant'],
      user: UserModel.fromJson(json['user']),
    );
  }
}