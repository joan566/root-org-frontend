
class RegisterUserResponseModel {
  final bool successfully;
  final String message;

  RegisterUserResponseModel({
    required this.successfully,
    required this.message,
  });

  factory RegisterUserResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterUserResponseModel(
      successfully: json['successfully'],
      message: json['message'],
    );
  }

}