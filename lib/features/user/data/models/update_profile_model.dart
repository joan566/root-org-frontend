import '../../../auth/data/models/user_model.dart';

class UpdateProfileModel {
  final bool successfully;
  final String message;
  final UserModel user;

  UpdateProfileModel({
      required this.successfully,
      required this.message,
      required this.user
  });

  factory UpdateProfileModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileModel(
        successfully: json['successfully'],
        message: json['message'],
        user: UserModel.fromJson(json['userInfo'])
    );
  }
}