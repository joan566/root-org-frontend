import 'package:flutter/material.dart';

import '../../../widgets/auth_form_layout.dart';
import '../../../state/auth_controller.dart';
import '../widgets/forgot_password_form.dart';

class ForgotPasswordDesktopView extends StatelessWidget {
  const ForgotPasswordDesktopView({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return AuthFormLayout(
      title: 'Recuperar contraseña',
      subtitle: 'Te enviaremos un enlace a tu correo.',
      desktop: true,
      artwork: AuthArtwork.recovery,
      child: ForgotPasswordForm(controller: controller),
    );
  }
}
