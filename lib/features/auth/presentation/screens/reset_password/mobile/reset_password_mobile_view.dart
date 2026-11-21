import 'package:flutter/material.dart';

import '../../../widgets/auth_form_layout.dart';
import '../../../state/auth_controller.dart';
import '../widgets/reset_password_form.dart';

class ResetPasswordMobileView extends StatelessWidget {
  const ResetPasswordMobileView({
    required this.controller,
    required this.resetToken,
    super.key,
  });

  final AuthController controller;
  final String resetToken;

  @override
  Widget build(BuildContext context) {
    return AuthFormLayout(
      title: 'Restablecer contraseña',
      subtitle: 'El enlace vence 10 minutos después de solicitarlo.',
      artwork: AuthArtwork.recovery,
      child: ResetPasswordForm(controller: controller, resetToken: resetToken),
    );
  }
}
