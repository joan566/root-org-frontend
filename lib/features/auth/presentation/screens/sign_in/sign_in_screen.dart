import 'package:flutter/material.dart';

import '../../../../../core/design_system/dimensions/app_breakpoints.dart';
import '../../state/auth_controller.dart';
import 'desktop/sign_in_desktop_view.dart';
import 'mobile/sign_in_mobile_view.dart';
import 'tablet/sign_in_tablet_view.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobile) {
          return SignInMobileView(controller: controller);
        }
        if (constraints.maxWidth < AppBreakpoints.desktop) {
          return SignInTabletView(controller: controller);
        }
        return SignInDesktopView(controller: controller);
      },
    );
  }
}
