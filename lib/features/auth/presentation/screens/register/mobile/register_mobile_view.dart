import 'package:flutter/material.dart';

import '../../../state/auth_controller.dart';
import '../../../widgets/auth_entry_layout.dart';
import '../widgets/register_form.dart';

class RegisterMobileView extends StatelessWidget {
  const RegisterMobileView({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return AuthEntryLayout(
      mode: AuthEntryLayoutMode.mobile,
      child: RegisterForm(controller: controller),
    );
  }
}
