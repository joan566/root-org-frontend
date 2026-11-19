import 'package:flutter/material.dart';

import '../../dimensions/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    final interactiveContent = onTap == null
        ? content
        : InkWell(onTap: onTap, child: content);
    final card = Card(
      margin: margin,
      clipBehavior: onTap == null ? Clip.none : Clip.antiAlias,
      child: interactiveContent,
    );

    if (semanticLabel == null) return card;
    return Semantics(label: semanticLabel, child: card);
  }
}
