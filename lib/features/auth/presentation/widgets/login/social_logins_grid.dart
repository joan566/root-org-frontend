import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class FutureSocialLoginsGrid extends StatelessWidget {
  const FutureSocialLoginsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildDisabledProviderButton('Google')),
        const SizedBox(width: 12),
        Expanded(child: _buildDisabledProviderButton('Microsoft')),
      ],
    );
  }

  Widget _buildDisabledProviderButton(String provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(color: AppColors.background.withOpacity(0.6), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(provider, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          _buildBadge(),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
      child: const Text('Próximamente', style: TextStyle(fontSize: 8, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
    );
  }
}
