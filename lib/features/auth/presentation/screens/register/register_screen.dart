import 'package:flutter/material.dart';

import '../../../../../core/design_system/dimensions/app_breakpoints.dart';
import '../../state/auth_controller.dart';
import 'desktop/register_desktop_view.dart';
import 'mobile/register_mobile_view.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth < AppBreakpoints.tablet
          ? RegisterMobileView(controller: controller)
          : RegisterDesktopView(controller: controller),
    );
  }
}
