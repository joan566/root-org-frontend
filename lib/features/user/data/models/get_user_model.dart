import '../../../auth/data/models/user_model.dart';

class GetUserModel {
  final bool successfully;
  final String message;
  final UserModel user;

  GetUserModel({
    required this.successfully,
    required this.message,
    required this.user
  });

  factory GetUserModel.fromJson(Map<String, dynamic> json) {
    return GetUserModel(
        successfully: json['successfully'],
        message: json['message'],
        user: UserModel.fromJson(json['userInfo'])
    );
  }
}