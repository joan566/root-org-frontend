
class VerifyCodeResponseModel {
  final bool successfully;
  final String message;
  final String resetToken;

  VerifyCodeResponseModel({
    required this.successfully,
    required this.message,
    required this.resetToken,
  });

  factory VerifyCodeResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyCodeResponseModel(
      successfully: json['successfully'],
      message: json['message'],
      resetToken: json['resetToken'],
    );
  }
}
