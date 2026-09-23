import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';
import 'package:savings_api_frontend/core/design_system/typography/app_typography.dart';
import '../../widgets/quick_actions_catalog.dart';

/// FAB de accesos rápidos del dashboard mobile (ver
/// docs/01-features/panel-principal.md §"Vista mobile"). En mobile, "Acciones
/// rápidas" no vive en el cuerpo del scroll (como en Desktop) sino detrás de
/// este botón flotante -- mismas 6 acciones reales de `quickActionsCatalog`
/// (compartido con `desktop/widgets/quick_actions_row.dart`).
///
/// Se usa como el último hijo de un `Stack` que llene el área del cuerpo
/// (`Positioned.fill(child: QuickActionsFab())`) -- así el scrim cubre
/// exactamente esa pantalla (por encima del bottom nav, que vive en el
/// `Scaffold` del shell, fuera de este `Stack`) sin necesitar un `Overlay`
/// aparte.
class QuickActionsFab extends StatefulWidget {
  const QuickActionsFab({super.key});

  @override
  State<QuickActionsFab> createState() => _QuickActionsFabState();
}

class _QuickActionsFabState extends State<QuickActionsFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  bool _open = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _open = !_open);
    if (_open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _close() {
    if (!_open) return;
    setState(() => _open = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut, reverseCurve: Curves.easeIn);

    return Stack(
      children: [
        if (_open)
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              child: AnimatedBuilder(
                animation: curved,
                builder: (context, child) => Container(color: Colors.black.withOpacity(0.25 * curved.value)),
              ),
            ),
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_open)
                  FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: curved,
                      alignment: Alignment.bottomRight,
                      child: _QuickActionsMenu(colors: colors, onSelect: _close),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                _Fab(open: _open, onTap: _toggle, colors: colors),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Fab extends StatelessWidget {
  final bool open;
  final VoidCallback onTap;
  final AppPalette colors;

  const _Fab({required this.open, required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.primary,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: AnimatedRotation(
              turns: open ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsMenu extends StatelessWidget {
  final AppPalette colors;
  final VoidCallback onSelect;

  const _QuickActionsMenu({required this.colors, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: colors.flatCardDecoration(radius: AppRadius.lg).copyWith(boxShadow: colors.premiumShadow()),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final action in quickActionsCatalog)
            _FabMenuItem(
              action: action,
              colors: colors,
              onTap: () {
                onSelect();
                navigateToQuickAction(context, action);
              },
            ),
        ],
      ),
    );
  }
}

class _FabMenuItem extends StatelessWidget {
  final QuickActionSpec action;
  final AppPalette colors;
  final VoidCallback onTap;

  const _FabMenuItem({required this.action, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: colors.primaryLight, borderRadius: AppRadius.borderMd),
                child: Icon(action.icon, color: colors.primary, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelLarge.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      action.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
