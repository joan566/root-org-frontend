import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class SectionTitle extends StatelessWidget {
  final int count;
  final bool isFiltered;

  const SectionTitle({super.key, required this.count, required this.isFiltered});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isFiltered ? 'Resultados encontrados' : 'Tus organizaciones asignadas',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary),
        ),
        Text(
          '$count en total',
          style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
