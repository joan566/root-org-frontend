import 'package:flutter/material.dart';

import '../../../state/auth_controller.dart';
import '../../../widgets/auth_entry_layout.dart';
import '../widgets/register_form.dart';

class RegisterTabletView extends StatelessWidget {
  const RegisterTabletView({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return AuthEntryLayout(
      mode: AuthEntryLayoutMode.tablet,
      child: RegisterForm(controller: controller),
    );
  }
}
