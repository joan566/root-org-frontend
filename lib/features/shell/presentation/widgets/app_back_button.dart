import 'package:flutter/material.dart';
import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';

import '../../../core/routes/app_navigator.dart';

class AppBackButton extends StatelessWidget {
  final String? label;
  final VoidCallback? onPressed;

  const AppBackButton({
    super.key,
    this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed ?? () => AppNavigator.pop(context),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: AppColors.premiumShadow(),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
              if (label != null) ...[
                const SizedBox(width: 8),
                Text(
                  label!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}