import 'package:flutter/material.dart';

import '../../dimensions/app_spacing.dart';
import '../buttons/app_button.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.message,
    super.key,
    this.title = 'No se pudo completar la operación',
    this.onRetry,
    this.retryLabel = 'Reintentar',
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: retryLabel,
                onPressed: onRetry,
                variant: AppButtonVariant.outlined,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
