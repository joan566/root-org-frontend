class ChangePasswordModel {
  final bool successfully;
  final String message;

  ChangePasswordModel({
    required this.successfully,
    required this.message
  });

  factory ChangePasswordModel.fromJson(Map<String, dynamic> json) {
    return ChangePasswordModel(successfully: json['successfully'], message: json['message']);
  }
}