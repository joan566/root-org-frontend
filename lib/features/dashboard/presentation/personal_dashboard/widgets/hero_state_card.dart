import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';


class HeroStateCard extends StatelessWidget {
  final bool hasOrganizations;

  const HeroStateCard({required this.hasOrganizations});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: colors.translucentCardDecoration(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: hasOrganizations ? colors.primaryLight : const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasOrganizations ? Icons.workspace_premium_rounded : Icons.gite_outlined,
              color: hasOrganizations ? colors.primary : colors.warning,
              size: 24,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            hasOrganizations ? 'Tu entorno está completamente listo.' : 'Todavía no perteneces a ninguna organización.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            hasOrganizations
                ? 'Selecciona una organización activa de tu panel para comenzar a auditar, estructurar datos y delegar roles de administración.'
                : 'Para comenzar el despliegue operativo del sistema, puedes fundar una nueva organización estructurada o ingresar un token de invitación enviado por tu administrador corporativo.',
            style: TextStyle(fontSize: 14, color: colors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: colors.textPrimary,
                  foregroundColor: colors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  hasOrganizations ? 'Ir a mis organizaciones' : 'Crear nueva organización',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              if (!hasOrganizations)
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.border, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Unirse con código', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
            ],
          )
        ],
      ),
    );
  }
}