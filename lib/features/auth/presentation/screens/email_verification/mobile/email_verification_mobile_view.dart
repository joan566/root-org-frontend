import 'package:flutter/material.dart';

import '../../../widgets/auth_form_layout.dart';
import '../../../state/auth_controller.dart';
import '../widgets/email_verification_form.dart';

class EmailVerificationMobileView extends StatelessWidget {
  const EmailVerificationMobileView({
    required this.controller,
    required this.email,
    super.key,
  });

  final AuthController controller;
  final String email;

  @override
  Widget build(BuildContext context) {
    return AuthFormLayout(
      title: 'Verifica tu correo',
      subtitle: 'Confirma tu dirección de correo electrónico.',
      artwork: AuthArtwork.verification,
      child: EmailVerificationForm(controller: controller, email: email),
    );
  }
}
