import 'package:flutter/material.dart';

import '../../../../core/design_system/colors/app_palette.dart';
import '../../../../core/design_system/dimensions/app_radius.dart';
import '../../../../core/design_system/dimensions/app_spacing.dart';

enum AuthArtwork { inventory, verification, recovery, security }

class RootOrgBrand extends StatelessWidget {
  const RootOrgBrand({
    super.key,
    this.centered = false,
    this.compact = false,
    this.darkBackground = false,
  });

  final bool centered;
  final bool compact;
  final bool darkBackground;

  @override
  Widget build(BuildContext context) {
    final useDarkLogo =
        darkBackground || Theme.of(context).brightness == Brightness.dark;
    final content = Image.asset(
      useDarkLogo
          ? 'assets/brand/logo-horizontal-dark.png'
          : 'assets/brand/logo-horizontal-light.png',
      width: compact ? 150 : 176,
      fit: BoxFit.contain,
    );

    return Semantics(
      label: 'RootOrg Inventory',
      child: centered ? Center(child: content) : content,
    );
  }
}

class AuthHeroPanel extends StatelessWidget {
  const AuthHeroPanel({required this.artwork, super.key});

  final AuthArtwork artwork;

  @override
  Widget build(BuildContext context) {
    final copy = switch (artwork) {
      AuthArtwork.inventory => (
        'El control de tu negocio, en orden.',
        'Gestiona tu inventario de forma simple, rápida y eficiente.',
      ),
      AuthArtwork.verification => (
        'Un paso más para proteger tu cuenta.',
        'Confirma tu correo para acceder a las herramientas de tu negocio.',
      ),
      AuthArtwork.recovery => (
        'Recupera el acceso con seguridad.',
        'Te ayudamos a volver a tu cuenta y seguir gestionando tu negocio.',
      ),
      AuthArtwork.security => (
        'Tu negocio, protegido.',
        'Mantén segura la información de tu cuenta.',
      ),
    };

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppPalette.brandGreen, Color(0xFF0B4037)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -65,
            child: _GlowCircle(
              size: 280,
              color: AppPalette.brandGreenLight.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -70,
            child: _GlowCircle(
              size: 300,
              color: AppPalette.brandAmberLight.withValues(alpha: 0.11),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RootOrgBrand(compact: true, darkBackground: true),
                const Spacer(),
                Center(child: _AuthArtwork(type: artwork)),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  copy.$1,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  copy.$2,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Organiza. Controla. Crece.',
                  style: TextStyle(
                    color: AppPalette.brandGreenLight,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthArtwork extends StatelessWidget {
  const _AuthArtwork({required this.type});

  final AuthArtwork type;

  @override
  Widget build(BuildContext context) {
    final (icon, accent) = switch (type) {
      AuthArtwork.inventory => (
        Icons.inventory_2_rounded,
        AppPalette.brandAmberLight,
      ),
      AuthArtwork.verification => (
        Icons.mark_email_read_rounded,
        AppPalette.brandGreenLight,
      ),
      AuthArtwork.recovery => (
        Icons.lock_reset_rounded,
        AppPalette.brandAmberLight,
      ),
      AuthArtwork.security => (
        Icons.verified_user_rounded,
        AppPalette.brandGreenLight,
      ),
    };

    return SizedBox(
      width: 260,
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _GlowCircle(size: 205, color: Colors.white.withValues(alpha: 0.08)),
          Positioned(
            bottom: 24,
            left: 36,
            child: Transform.rotate(
              angle: -0.12,
              child: _ArtworkTile(
                icon: Icons.checklist_rounded,
                color: Colors.white,
                iconColor: AppPalette.brandGreen,
                size: 75,
              ),
            ),
          ),
          Positioned(
            top: 24,
            right: 27,
            child: _ArtworkTile(
              icon: Icons.trending_up_rounded,
              color: AppPalette.brandGreenLight,
              iconColor: const Color(0xFF104B3E),
              size: 64,
            ),
          ),
          _ArtworkTile(
            icon: icon,
            color: accent,
            iconColor: const Color(0xFF153D34),
            size: 118,
          ),
          Positioned(
            bottom: 22,
            right: 32,
            child: _ArtworkTile(
              icon: Icons.inventory_2_rounded,
              color: const Color(0xFFD8A15B),
              iconColor: const Color(0xFF70451F),
              size: 57,
            ),
          ),
          Positioned(
            top: 25,
            left: 34,
            child: Icon(
              Icons.auto_graph_rounded,
              color: Colors.white.withValues(alpha: 0.64),
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtworkTile extends StatelessWidget {
  const _ArtworkTile({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.54, color: iconColor),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
