import 'package:flutter/material.dart';

import '../../../../../core/design_system/dimensions/app_breakpoints.dart';
import '../../state/auth_controller.dart';
import 'desktop/email_verification_desktop_view.dart';
import 'mobile/email_verification_mobile_view.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({
    required this.controller,
    required this.email,
    super.key,
  });

  final AuthController controller;
  final String email;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth < AppBreakpoints.tablet
          ? EmailVerificationMobileView(controller: controller, email: email)
          : EmailVerificationDesktopView(controller: controller, email: email),
    );
  }
}
