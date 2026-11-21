import 'package:flutter/material.dart';

import '../../../../core/design_system/dimensions/app_breakpoints.dart';
import '../../../../core/design_system/dimensions/app_radius.dart';
import '../../../../core/design_system/dimensions/app_spacing.dart';
import 'auth_branding.dart';

enum AuthEntryLayoutMode { mobile, tablet, desktop }

enum AuthFeedbackType { error, success }

class AuthEntryLayout extends StatelessWidget {
  const AuthEntryLayout({required this.mode, required this.child, super.key});

  final AuthEntryLayoutMode mode;
  final Widget child;

  @override
  Widget build(BuildContext context) => switch (mode) {
    AuthEntryLayoutMode.mobile => _buildMobile(),
    AuthEntryLayoutMode.tablet => _buildTablet(),
    AuthEntryLayoutMode.desktop => _buildDesktop(context),
  };

  Widget _buildMobile() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _AuthFormSurface(child: child),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTablet() {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minHeight = (constraints.maxHeight - AppSpacing.xl * 2)
                .clamp(0.0, double.infinity)
                .toDouble();

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppBreakpoints.mobile,
                    ),
                    child: _AuthFormSurface(child: child),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minHeight = (constraints.maxHeight - AppSpacing.xl * 2)
                .clamp(0.0, double.infinity)
                .toDouble();

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AppBreakpoints.desktop,
                    minHeight: minHeight,
                  ),
                  child: _DesktopAuthSurface(child: child),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AuthEntryHeader extends StatelessWidget {
  const AuthEntryHeader({
    required this.showTagline,
    required this.message,
    required this.feedbackType,
    super.key,
  });

  final bool showTagline;
  final String? message;
  final AuthFeedbackType? feedbackType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const RootOrgBrand(centered: true, compact: true),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: showTagline
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    'Organiza tu negocio. Crece con claridad.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => SizeTransition(
            sizeFactor: animation,
            alignment: Alignment.topCenter,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: message == null || feedbackType == null
              ? const SizedBox.shrink(key: ValueKey('no-auth-feedback'))
              : Padding(
                  key: ValueKey('$feedbackType:$message'),
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: AuthFeedbackBanner(
                    message: message!,
                    type: feedbackType!,
                  ),
                ),
        ),
      ],
    );
  }
}

class AuthFeedbackBanner extends StatelessWidget {
  const AuthFeedbackBanner({
    required this.message,
    required this.type,
    super.key,
  });

  final String message;
  final AuthFeedbackType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isError = type == AuthFeedbackType.error;
    final backgroundColor = isError
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;
    final foregroundColor = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onPrimaryContainer;

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: foregroundColor.withValues(alpha: 0.12)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline,
              size: 20,
              color: foregroundColor,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: foregroundColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthFieldShake extends StatefulWidget {
  const AuthFieldShake({required this.trigger, required this.child, super.key});

  final int trigger;
  final Widget child;

  @override
  State<AuthFieldShake> createState() => _AuthFieldShakeState();
}

class _AuthFieldShakeState extends State<AuthFieldShake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _offset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -5), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -5, end: 5), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 5, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: -4, end: 3), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 3, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant AuthFieldShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger &&
        !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    return AnimatedBuilder(
      animation: _offset,
      child: widget.child,
      builder: (context, child) =>
          Transform.translate(offset: Offset(_offset.value, 0), child: child),
    );
  }
}

class _AuthFormSurface extends StatelessWidget {
  const _AuthFormSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}

class _DesktopAuthSurface extends StatelessWidget {
  const _DesktopAuthSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(flex: 5, child: _AuthIdentityPanel()),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xl,
                  ),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthIdentityPanel extends StatelessWidget {
  const _AuthIdentityPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.primaryContainer),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Text(
              'Gestiona tu operación con claridad.',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Inventario y procesos de tu negocio, reunidos en un espacio de trabajo.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _WorkspacePreview(),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    'Acceso seguro a tu espacio de trabajo',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkspacePreview extends StatelessWidget {
  const _WorkspacePreview();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.space_dashboard_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Espacio de trabajo',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Icon(
                  Icons.more_horiz_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Divider(height: 1, color: colorScheme.outlineVariant),
            const SizedBox(height: AppSpacing.xs),
            const _WorkspacePreviewRow(
              icon: Icons.inventory_2_outlined,
              label: 'Productos',
            ),
            const _WorkspacePreviewRow(
              icon: Icons.category_outlined,
              label: 'Categorías',
            ),
            const _WorkspacePreviewRow(
              icon: Icons.swap_horiz_rounded,
              label: 'Movimientos',
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkspacePreviewRow extends StatelessWidget {
  const _WorkspacePreviewRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
