import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import '../bottom_sheets/create_or_join_bottom_sheet.dart';

class TenantFloatingActions extends StatelessWidget {
  final VoidCallback onJoin;
  final VoidCallback onCreate;

  const TenantFloatingActions({super.key, required this.onJoin, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        showCreateOrJoinBottomSheet(context, onCreate: onCreate, onJoin: onJoin);
      },
      backgroundColor: AppColors.textPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.primary),
      label: const Text('Nueva organización', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}
