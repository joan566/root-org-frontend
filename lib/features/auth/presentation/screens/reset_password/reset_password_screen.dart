import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/design_system/dimensions/app_breakpoints.dart';
import '../../../../../core/design_system/components/feedback/app_error_state.dart';
import '../../state/auth_controller.dart';
import 'desktop/reset_password_desktop_view.dart';
import 'mobile/reset_password_mobile_view.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    required this.controller,
    required this.resetToken,
    super.key,
    this.removeTokenFromUrl = false,
  });

  final AuthController controller;
  final String? resetToken;
  final bool removeTokenFromUrl;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.removeTokenFromUrl && widget.resetToken != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.replace('/auth/reset-password', extra: widget.resetToken);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetToken = widget.resetToken;
    if (resetToken == null || resetToken.isEmpty) {
      return const Scaffold(
        body: AppErrorState(
          title: 'Enlace incompleto',
          message:
              'Solicita un nuevo enlace de recuperación e inténtalo nuevamente.',
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth < AppBreakpoints.tablet
          ? ResetPasswordMobileView(
              controller: widget.controller,
              resetToken: resetToken,
            )
          : ResetPasswordDesktopView(
              controller: widget.controller,
              resetToken: resetToken,
            ),
    );
  }
}
