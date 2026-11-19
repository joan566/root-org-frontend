class LoginRequestModel {
  const LoginRequestModel({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequestModel {
  const RegisterRequestModel({
    required this.name,
    required this.email,
    required this.password,
    this.phoneNumber,
  });

  final String name;
  final String email;
  final String? phoneNumber;
  final String password;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
    'password': password,
  };
}

class RefreshTokenRequestModel {
  const RefreshTokenRequestModel(this.refreshToken);

  final String refreshToken;

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

class EmailRequestModel {
  const EmailRequestModel(this.email);

  final String email;

  Map<String, dynamic> toJson() => {'email': email};
}

class ConfirmEmailRequestModel {
  const ConfirmEmailRequestModel({required this.email, required this.code});

  final String email;
  final String code;

  Map<String, dynamic> toJson() => {'email': email, 'code': code};
}

class ResetPasswordRequestModel {
  const ResetPasswordRequestModel({
    required this.resetToken,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String resetToken;
  final String newPassword;
  final String confirmPassword;

  Map<String, dynamic> toJson() => {
    'resetToken': resetToken,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };
}

class ChangePasswordRequestModel {
  const ChangePasswordRequestModel({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  Map<String, dynamic> toJson() => {
    'oldPassword': oldPassword,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };
}
