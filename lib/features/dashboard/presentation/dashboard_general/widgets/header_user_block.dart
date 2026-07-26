import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class HeaderUserBlock extends StatelessWidget {
  final bool isScrolledDark;
  final String userName;
  final String? activeOrganizationName;
  final bool canSwitchOrganization;
  final VoidCallback? onTapOrganization;

  const HeaderUserBlock({
    super.key,
    required this.isScrolledDark,
    required this.userName,
    this.activeOrganizationName,
    this.canSwitchOrganization = false,
    this.onTapOrganization,
  });

  String get _initials => userName.trim().isEmpty ? '?' : userName.trim()[0].toUpperCase();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textColor = isScrolledDark ? colors.textPrimary : Colors.white;
    final subColor = isScrolledDark ? colors.textSecondary : Colors.white.withOpacity(0.6);
    final avatarBorder = isScrolledDark ? colors.border : Colors.white24;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                      child: Text('Hola, $userName'),
                    ),
                    const SizedBox(width: 6),
                    const Text('👋', style: TextStyle(fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: subColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  child: const Text(
                    'Bienvenido nuevamente. Administra tu cuenta y accede a tus organizaciones.',
                  ),
                ),
                if (activeOrganizationName != null) ...[
                  const SizedBox(height: 10),
                  _OrganizationChip(
                    name: activeOrganizationName!,
                    interactive: canSwitchOrganization,
                    isScrolledDark: isScrolledDark,
                    onTap: onTapOrganization,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: avatarBorder,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.primary.withOpacity(0.2),
                  child: Text(
                    _initials,
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: isScrolledDark ? Colors.white : colors.slateDark, width: 2.5),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

/// Pill con la organización activa. Si `interactive` (2+ organizaciones),
/// toca para abrir el selector y cambiar cuál está activa.
class _OrganizationChip extends StatelessWidget {
  final String name;
  final bool interactive;
  final bool isScrolledDark;
  final VoidCallback? onTap;

  const _OrganizationChip({
    required this.name,
    required this.interactive,
    required this.isScrolledDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final fg = isScrolledDark ? colors.textPrimary : Colors.white;
    final bg = isScrolledDark ? colors.surface : Colors.white.withOpacity(0.14);
    final border = isScrolledDark ? colors.border : Colors.white24;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: interactive ? onTap : null,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.apartment_rounded, size: 14, color: fg.withOpacity(0.8)),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              if (interactive) ...[
                const SizedBox(width: 4),
                Icon(Icons.unfold_more_rounded, size: 14, color: fg.withOpacity(0.7)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
