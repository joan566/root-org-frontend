import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class PasswordFormCard extends StatelessWidget {
  final Widget child;
  final GlobalKey<FormState> formKey;

  const PasswordFormCard({
    super.key,
    required this.child,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: colors.premiumShadow(),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(28),
      child: Form(
        key: formKey,
        child: child,
      ),
    );
  }
}
