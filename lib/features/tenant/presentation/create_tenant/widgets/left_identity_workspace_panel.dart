import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class LeftIdentityWorkspacePanel extends StatelessWidget {
  const LeftIdentityWorkspacePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.slateDark,
      child: Stack(
        children: [
          Positioned.fill(child: Opacity(opacity: 0.02, child: CustomPaint(painter: _GridPainter()))),
          Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.blur_on_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('SUMKEYA OS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Crea tu primera organización.', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    const SizedBox(height: 12),
                    Text('Las organizaciones actúan como espacios aislados e independientes (multi-tenant) donde podrás gestionar flujos de trabajo, asignar roles e integrar módulos de control.', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.5)),
                    const SizedBox(height: 32),
                    _buildFeatureRow('Administración centralizada avanzada'),
                    _buildFeatureRow('Miembros con granularidad de roles jerárquicos'),
                    _buildFeatureRow('Aprovisionamiento de módulos bajo demanda'),
                    _buildFeatureRow('Aislamiento lógico estricto de bases de datos'),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.06))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('¿Qué sucede al crear una organización?', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildStepSequenceLine('1', 'Estructuración lógica del Tenant en la nube.'),
                      _buildStepSequenceLine('2', 'Auto-asignación de tu perfil como Administrador.'),
                      _buildStepSequenceLine('3', 'Generación automatizada de llaves de invitación compartidas.'),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 16),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStepSequenceLine(String number, String step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(step, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11))),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.15)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    double step = 54.0;
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
