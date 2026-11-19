import 'package:flutter/material.dart';

import '../../../../../core/design_system/dimensions/app_breakpoints.dart';
import '../../state/auth_controller.dart';
import 'desktop/forgot_password_desktop_view.dart';
import 'mobile/forgot_password_mobile_view.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth < AppBreakpoints.tablet
          ? ForgotPasswordMobileView(controller: controller)
          : ForgotPasswordDesktopView(controller: controller),
    );
  }
}
