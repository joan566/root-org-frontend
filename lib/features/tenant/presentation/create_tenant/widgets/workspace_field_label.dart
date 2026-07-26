import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class WorkspaceFieldLabel extends StatelessWidget {
  final String label;
  const WorkspaceFieldLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary));
  }
}
