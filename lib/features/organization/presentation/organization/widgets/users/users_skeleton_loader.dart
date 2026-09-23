import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/radius/app_radius.dart';
import 'package:savings_api_frontend/core/design_system/spacing/app_spacing.dart';

/// Placeholder de carga de la pestaña Usuarios -- pulso sutil, sin
/// dependencias nuevas (no hay paquete de shimmer en el proyecto).
class UsersSkeletonLoader extends StatefulWidget {
  const UsersSkeletonLoader({super.key});

  @override
  State<UsersSkeletonLoader> createState() => _UsersSkeletonLoaderState();
}

class _UsersSkeletonLoaderState extends State<UsersSkeletonLoader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          for (int i = 0; i < 5; i++) ...[
            const _PulsingBlock(height: 84),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _PulsingBlock extends StatefulWidget {
  final double height;

  const _PulsingBlock({required this.height});

  @override
  State<_PulsingBlock> createState() => _PulsingBlockState();
}

class _PulsingBlockState extends State<_PulsingBlock> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(color: colors.background, borderRadius: AppRadius.borderLg),
      ),
    );
  }
}
