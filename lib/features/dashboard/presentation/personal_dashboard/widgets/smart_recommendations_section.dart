import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class SmartRecommendationsSection extends StatelessWidget {
  final List<Map<String, String>> recommendations;
  final Function(String) onDismiss;

  const SmartRecommendationsSection({
    required this.recommendations,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text('Recomendaciones para ti', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ),
        ...recommendations.map((rec) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildDismissibleTip(
            id: rec['id']!,
            title: rec['title']!,
            desc: rec['desc']!,
            btnLabel: rec['btnLabel']!,
          ),
        )),
      ],
    );
  }

  Widget _buildDismissibleTip({required String id, required String title, required String desc, required String btnLabel}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.translucentCardDecoration(radius: 16), // Corregido[cite: 1]
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.background,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(btnLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => onDismiss(id),
            icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
            style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          )
        ],
      ),
    );
  }
}