import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class ProfileCompletionCard extends StatelessWidget {
  final double completionPercentage;
  final int pendingCount;

  const ProfileCompletionCard({required this.completionPercentage, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: colors.subtleShadow(),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: colors.primaryLight, shape: BoxShape.circle),
                    child: Icon(Icons.bolt_rounded, color: colors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text('Perfil Profesional', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                ],
              ),
              Text(
                '${(completionPercentage * 100).toInt()}% completo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colors.primary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Completa la verificación corporativa para desbloquear herramientas avanzadas de administración multi-tenant.',
            style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completionPercentage,
              minHeight: 8,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: colors.warning, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(
                '$pendingCount requerimientos empresariales pendientes',
                style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          )
        ],
      ),
    );
  }
}