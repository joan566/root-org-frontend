import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class LiveWorkspacePreviewCard extends StatelessWidget {
  final String name;
  final String description;

  const LiveWorkspacePreviewCard({super.key, required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.slateDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text('VISTA PREVIA EN TIEMPO REAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.4), letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 36),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            name.isEmpty ? 'Nombre de tu Organización' : name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: name.isEmpty ? Colors.white.withOpacity(0.2) : Colors.white, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            description.isEmpty ? 'Sin descripción configurada aún. Comienza a escribir en el panel de control izquierdo para rellenar este espectro informativo.' : description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(description.isEmpty ? 0.25 : 0.6), height: 1.5),
          ),
          const SizedBox(height: 28),
          Divider(color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 16),
          _buildPreviewMetaRow(Icons.shield_outlined, 'Rol asignado', 'Administrador Principal (Tú)'),
          const SizedBox(height: 12),
          _buildPreviewMetaRow(Icons.people_alt_outlined, 'Miembros iniciales', '1 miembro operativo'),
          const SizedBox(height: 12),
          _buildPreviewMetaRow(Icons.layers_outlined, 'Módulos base', 'Espera de aprovisionamiento'),
        ],
      ),
    );
  }

  Widget _buildPreviewMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.4), size: 16),
        const SizedBox(width: 12),
        Text('$label:', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4))),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}
