
import 'package:savings_api_frontend/features/auth/data/datasources/auth_api.dart';
import 'package:savings_api_frontend/features/auth/data/repositories/auth_repository_adapter.dart';
import 'package:savings_api_frontend/features/auth/domain/usecases/login_user_case.dart';
import 'package:savings_api_frontend/features/auth/domain/usecases/register_user_use_case.dart';
import 'package:savings_api_frontend/features/auth/domain/usecases/forgot_password_use_case.dart';
import 'package:savings_api_frontend/features/auth/domain/usecases/verify_code_use_case.dart';
import 'package:savings_api_frontend/features/auth/domain/usecases/reset_password_use_case.dart';
import 'package:savings_api_frontend/features/auth/presentation/login/state/login_controller.dart';
import 'package:savings_api_frontend/features/auth/presentation/register/state/register_controller.dart';
import 'package:savings_api_frontend/features/auth/presentation/state/forgot_password_controller.dart';

class AuthInjection {
  static LoginController login() {
    final authApi = AuthApi();
    final repository = AuthRepositoryAdapter(authApi);
    final useCase = LoginUserUseCase(repository);

    return LoginController(useCase);
  }

  static RegisterController register() {
    final authApi = AuthApi();
    final repository = AuthRepositoryAdapter(authApi);
    final useCase = RegisterUserUseCase(repository);

    return RegisterController(useCase);
  }

  static ForgotPasswordController forgotPassword() {
    final authApi = AuthApi();
    final repository = AuthRepositoryAdapter(authApi);
    
    return ForgotPasswordController(
      forgotPasswordUseCase: ForgotPasswordUseCase(repository),
      verifyCodeUseCase: VerifyCodeUseCase(repository),
      resetPasswordUseCase: ResetPasswordUseCase(repository),
    );
  }
}
