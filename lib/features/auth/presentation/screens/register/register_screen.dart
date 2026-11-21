import 'package:flutter/material.dart';

import '../../../../../core/design_system/dimensions/app_breakpoints.dart';
import '../../state/auth_controller.dart';
import 'desktop/register_desktop_view.dart';
import 'mobile/register_mobile_view.dart';
import 'tablet/register_tablet_view.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobile) {
          return RegisterMobileView(controller: controller);
        }
        if (constraints.maxWidth < AppBreakpoints.desktop) {
          return RegisterTabletView(controller: controller);
        }
        return RegisterDesktopView(controller: controller);
      },
    );
  }
}
