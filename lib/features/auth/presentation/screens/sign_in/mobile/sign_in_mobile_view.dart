import 'package:flutter/material.dart';

import '../../../state/auth_controller.dart';
import '../../../widgets/auth_entry_layout.dart';
import '../widgets/sign_in_form.dart';

class SignInMobileView extends StatelessWidget {
  const SignInMobileView({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return AuthEntryLayout(
      mode: AuthEntryLayoutMode.mobile,
      child: SignInForm(controller: controller),
    );
  }
}
