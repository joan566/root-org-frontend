import 'package:flutter/material.dart';

import '../../../state/auth_controller.dart';
import '../../../widgets/auth_entry_layout.dart';
import '../widgets/sign_in_form.dart';

class SignInDesktopView extends StatelessWidget {
  const SignInDesktopView({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return AuthEntryLayout(
      mode: AuthEntryLayoutMode.desktop,
      child: SignInForm(controller: controller),
    );
  }
}
