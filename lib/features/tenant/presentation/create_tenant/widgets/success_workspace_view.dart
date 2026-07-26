import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'workspace_next_steps_checklist.dart';

class SuccessWorkspaceView extends StatelessWidget {
  final String organizationName;
  final String invitationCode;
  final VoidCallback onContinue;

  const SuccessWorkspaceView({
    super.key,
    required this.organizationName,
    required this.invitationCode,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.premiumShadow(),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                      child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 36),
                    ),
                    const SizedBox(height: 20),
                    const Text('¡Espacio corporativo listo!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                    const SizedBox(height: 6),
                    Text('La organización "$organizationName" se ha estructurado con éxito en el backend global.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('CÓDIGO DE INVITACIÓN REAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                                child: const Text('ACTIVO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF16A34A))),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  invitationCode,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 2.0),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.textSecondary),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: invitationCode));
                                  HapticFeedback.lightImpact();
                                },
                                tooltip: 'Copiar código',
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: AppColors.border),
                          const Row(
                            children: [
                              Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSecondary),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Comparte este código con tu equipo de trabajo para permitirles unirse de manera directa.',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    const WorkspaceNextStepsChecklist(),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: onContinue,
                        style: FilledButton.styleFrom(backgroundColor: AppColors.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Acceder al Dashboard Principal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
