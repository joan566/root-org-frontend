import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class LeftIdentityPanel extends StatelessWidget {
  const LeftIdentityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.slateDark,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.02,
              child: CustomPaint(painter: GridPatternPainter()),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(54.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.blur_on_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'SUMKEYA',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Las redes unidas mantienen a todos avanzando.',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1.0, height: 1.25),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Centraliza organizaciones, módulos y equipos desde un único lugar.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, height: 1.5),
                    ),
                    const SizedBox(height: 36),
                    _buildBenefitItem('Administración multi-organización'),
                    _buildBenefitItem('Seguridad empresarial'),
                    _buildBenefitItem('Arquitectura modular'),
                    _buildBenefitItem('Escalable'),
                    _buildBenefitItem('Información centralizada'),
                    _buildBenefitItem('Acceso desde cualquier dispositivo'),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IndicatorInfoBlock(title: 'Organizaciones', desc: 'Más de 500 activas'),
                    IndicatorInfoBlock(title: 'Disponibilidad', desc: '99.9% de uptime garantizado'),
                    IndicatorInfoBlock(title: 'Protección', desc: 'Información protegida'),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 16),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class IndicatorInfoBlock extends StatelessWidget {
  final String title;
  final String desc;
  const IndicatorInfoBlock({super.key, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
      ],
    );
  }
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.3)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    double step = 48.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
