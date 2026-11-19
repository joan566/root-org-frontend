import 'package:flutter/material.dart';

import '../../../widgets/auth_form_layout.dart';
import '../../../state/auth_controller.dart';
import '../widgets/register_form.dart';

class RegisterDesktopView extends StatelessWidget {
  const RegisterDesktopView({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return AuthFormLayout(
      title: 'Crear cuenta',
      subtitle: 'Regístrate para empezar a usar RootOrg.',
      desktop: true,
      child: RegisterForm(controller: controller),
    );
  }
}
