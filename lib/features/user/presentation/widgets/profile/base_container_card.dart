import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:savings_api_frontend/features/core/presentation/styles/app_colors.dart';

class BaseContainerCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const BaseContainerCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.subtleShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.textPrimary),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.2)),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          ...children,
        ],
      ),
    );
  }
}