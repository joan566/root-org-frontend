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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.premiumShadow(),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(28),
      child: Form(
        key: formKey,
        child: child,
      ),
    );
  }
}
