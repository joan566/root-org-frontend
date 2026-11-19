import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, outlined, text, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveOnPressed = isLoading ? null : onPressed;
    final child = Semantics(
      label: isLoading ? label : null,
      child: _buildChild(theme.colorScheme),
    );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.secondary => FilledButton.tonal(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.destructive => FilledButton(
        onPressed: effectiveOnPressed,
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
        ),
        child: child,
      ),
    };

    return isExpanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  Widget _buildChild(ColorScheme colorScheme) {
    if (isLoading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: variant == AppButtonVariant.destructive
              ? colorScheme.onError
              : null,
        ),
      );
    }

    if (icon == null) return Text(label);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
    );
  }
}
