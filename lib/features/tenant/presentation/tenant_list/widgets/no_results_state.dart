import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class NoResultsState extends StatelessWidget {
  final String query;
  const NoResultsState({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
            child: Icon(Icons.search_off_rounded, size: 36, color: colors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text('Sin resultados', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            'No encontramos ninguna organización que coincida con "$query".',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
