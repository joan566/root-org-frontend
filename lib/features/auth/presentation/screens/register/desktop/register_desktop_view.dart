import 'package:flutter/material.dart';

import '../../../state/auth_controller.dart';
import '../../../widgets/auth_entry_layout.dart';
import '../widgets/register_form.dart';

class RegisterDesktopView extends StatelessWidget {
  const RegisterDesktopView({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return AuthEntryLayout(
      mode: AuthEntryLayoutMode.desktop,
      child: RegisterForm(controller: controller),
    );
  }
}
