import 'package:flutter/material.dart';

import '../../../widgets/auth_form_layout.dart';
import '../../../state/auth_controller.dart';
import '../widgets/change_password_form.dart';

class ChangePasswordDesktopView extends StatelessWidget {
  const ChangePasswordDesktopView({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return AuthFormLayout(
      title: 'Cambiar contraseña',
      subtitle: 'Actualiza la contraseña de tu cuenta.',
      desktop: true,
      artwork: AuthArtwork.security,
      child: ChangePasswordForm(controller: controller),
    );
  }
}
