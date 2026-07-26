import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class ProfileCompletionCard extends StatelessWidget {
  final double completionPercentage;
  final int pendingCount;

  const ProfileCompletionCard({required this.completionPercentage, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.subtleShadow(),
        border: Border.all(color: AppColors.border),
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
                    decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                    child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text('Perfil Profesional', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
              Text(
                '${(completionPercentage * 100).toInt()}% completo',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Completa la verificación corporativa para desbloquear herramientas avanzadas de administración multi-tenant.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completionPercentage,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(
                '$pendingCount requerimientos empresariales pendientes',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          )
        ],
      ),
    );
  }
}