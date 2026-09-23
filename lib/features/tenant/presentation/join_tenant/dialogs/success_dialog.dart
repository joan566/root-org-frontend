import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class SuccessDialog extends StatefulWidget {
  final Animation<double> animation;
  final VoidCallback onContinue;
  final String title;
  final String message;

  const SuccessDialog({
    super.key,
    required this.animation,
    required this.onContinue,
    this.title = '¡Bienvenido!',
    this.message = 'Ahora haces parte de la organización.',
  });

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _iconScale = CurvedAnimation(parent: _iconController, curve: Curves.elasticOut);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _iconController.forward();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return ScaleTransition(
      scale: CurvedAnimation(parent: widget.animation, curve: Curves.easeOutBack),
      child: FadeTransition(
        opacity: widget.animation,
        child: AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(32),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _iconScale,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: colors.primaryLight, shape: BoxShape.circle),
                  child: Icon(Icons.check_circle_rounded, color: colors.primary, size: 48),
                ),
              ),
              const SizedBox(height: 24),
              Text(widget.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text(widget.message, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: colors.textSecondary)),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: widget.onContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.textPrimary,
                    foregroundColor: colors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Continuar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
