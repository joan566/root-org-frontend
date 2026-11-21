import 'package:flutter/material.dart';

import '../../../state/auth_controller.dart';
import '../../../widgets/auth_entry_layout.dart';
import '../widgets/sign_in_form.dart';

class SignInTabletView extends StatelessWidget {
  const SignInTabletView({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return AuthEntryLayout(
      mode: AuthEntryLayoutMode.tablet,
      child: SignInForm(controller: controller),
    );
  }
}
