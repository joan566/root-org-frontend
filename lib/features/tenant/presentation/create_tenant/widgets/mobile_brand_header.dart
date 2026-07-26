import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class MobileBrandHeader extends StatelessWidget {
  const MobileBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: AppColors.slateDark, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.blur_on_rounded, color: AppColors.primary, size: 14),
        ),
        const SizedBox(width: 8),
        const Text('SUMKEYA OS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 0.5)),
      ],
    );
  }
}
