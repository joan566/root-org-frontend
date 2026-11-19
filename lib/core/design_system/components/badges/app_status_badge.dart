import 'package:flutter/material.dart';

import '../../dimensions/app_spacing.dart';

enum AppStatusTone { neutral, info, success, warning, danger }

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    required this.label,
    super.key,
    this.tone = AppStatusTone.neutral,
    this.icon,
  });

  final String label;
  final AppStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = switch (tone) {
      AppStatusTone.neutral => colorScheme.onSurfaceVariant,
      AppStatusTone.info => colorScheme.primary,
      AppStatusTone.success => colorScheme.primary,
      AppStatusTone.warning => colorScheme.secondary,
      AppStatusTone.danger => colorScheme.error,
    };

    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: foregroundColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: foregroundColor),
                  const SizedBox(width: AppSpacing.xxs),
                ],
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: foregroundColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
