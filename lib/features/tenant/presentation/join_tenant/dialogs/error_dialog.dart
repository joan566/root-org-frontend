import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class ErrorDialog extends StatelessWidget {
  final String errorMessage;
  const ErrorDialog({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      contentPadding: const EdgeInsets.all(28),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: colors.error.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.gpp_bad_rounded, color: colors.error, size: 36),
          ),
          const SizedBox(height: 20),
          Text('Error de vinculación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary, letterSpacing: -0.4)),
          const SizedBox(height: 10),
          Text(errorMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.4)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Entendido', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary)),
            ),
          )
        ],
      ),
    );
  }
}
