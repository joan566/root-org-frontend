import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';

class NoActiveOrganizationView extends StatefulWidget {
  final VoidCallback onCreateOrganization;
  final VoidCallback onJoinOrganization;

  const NoActiveOrganizationView({
    super.key,
    required this.onCreateOrganization,
    required this.onJoinOrganization,
  });

  @override
  State<NoActiveOrganizationView> createState() => _NoActiveOrganizationViewState();
}

class _NoActiveOrganizationViewState extends State<NoActiveOrganizationView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);

    _floatAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: const Offset(0, -0.05))
        .animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOutQuad));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeController,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildArtSection(),
              const SizedBox(height: 32),
              Text(
                "Aún no tienes una organización activa",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Crea una organización o únete a un equipo existente para\ncomenzar a gestionar tus módulos y recursos.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildActionButtons(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtSection() {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.maxWidth > 600 ? 280.0 : 220.0;
      return SizedBox(
        height: size,
        width: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.04),
              ),
            ),
            SlideTransition(
              position: _floatAnimation,
              child: SvgPicture.asset(
                'assets/illustrations/no_active_tenant.svg',
                width: size * 0.7,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        FilledButton.icon(
          onPressed: widget.onCreateOrganization,
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: const Text("Crear organización"),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: widget.onJoinOrganization,
          icon: const Icon(Icons.link_rounded),
          label: const Text("Unirme a una organización"),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}