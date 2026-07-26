import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_palette.dart';

class RegisterSocialLoginsGrid extends StatelessWidget {
  const RegisterSocialLoginsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      children: [
        Expanded(child: _buildDisabledProviderButton(colors, 'Google')),
        const SizedBox(width: 12),
        Expanded(child: _buildDisabledProviderButton(colors, 'GitHub')),
      ],
    );
  }

  Widget _buildDisabledProviderButton(AppPalette colors, String provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(color: colors.background.withOpacity(0.6), borderRadius: BorderRadius.circular(10), border: Border.all(color: colors.border)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(provider, style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(4)),
            child: Text('Próximamente', style: TextStyle(fontSize: 7, color: colors.textSecondary, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
