import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class BaseContainerCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const BaseContainerCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: colors.subtleShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Row(
              children: [
                Icon(icon, size: 18, color: colors.textPrimary),
                const SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textPrimary, letterSpacing: -0.2)),
              ],
            ),
          ),
          Divider(color: colors.border, height: 1),
          ...children,
        ],
      ),
    );
  }
}