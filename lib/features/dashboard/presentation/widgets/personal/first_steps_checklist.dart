import 'package:flutter/material.dart';
import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';

class FirstStepsChecklist extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  // Mantenemos la firma por compatibilidad, pero deshabilitaremos el toggle manual para datos reales del perfil
  final Function(int)? onToggle;

  const FirstStepsChecklist({
    super.key,
    required this.items,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Cálculo en tiempo real de tareas completadas
    final int completedCount = items.where((item) => item['isDone'] == true).length;
    final double progressValue = items.isNotEmpty ? completedCount / items.length : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.translucentCardDecoration(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Primeros pasos',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso del entorno',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                '$completedCount de ${items.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary, // Se alinea a la paleta corporativa
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Barra de progreso animada de forma nativa al cambiar los valores
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progressValue),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppColors.background,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ...List.generate(items.length, (index) {
            final item = items[index];
            final bool isDone = item['isDone'] == true;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: InkWell(
                // Deshabilitamos el onTap si no hay una acción manual definida,
                // ya que estos campos ahora se validan automáticamente con el backend
                onTap: onToggle != null ? () => onToggle!(index) : null,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                  child: Row(
                    children: [
                      // Icono con cambio de estado animado
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          key: ValueKey<bool>(isDone),
                          color: isDone ? AppColors.success : AppColors.textMuted,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isDone ? FontWeight.normal : FontWeight.w500,
                            color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                            decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                          child: Text(item['text']),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}