import 'package:flutter/material.dart';

import '../../../widgets/auth_form_layout.dart';
import '../widgets/sign_in_form.dart';
import '../../../state/auth_controller.dart';

class SignInDesktopView extends StatelessWidget {
  const SignInDesktopView({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return AuthFormLayout(
      title: 'Iniciar sesión',
      subtitle: 'Ingresa a tu cuenta para continuar.',
      desktop: true,
      child: SignInForm(controller: controller),
    );
  }
}
