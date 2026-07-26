import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import 'avatar_progress_painter.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final String lastName;
  final double percentage;

  const ProfileAvatar({required this.name, required this.lastName, required this.percentage});

  @override
  Widget build(BuildContext context) {
    final String initials = '${name.isNotEmpty ? name[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
    final bool isComplete = percentage >= 1.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(84, 84),
          painter: AvatarProgressPainter(
            progress: percentage,
            color: isComplete ? AppColors.success : AppColors.primary,
          ),
        ),
        CircleAvatar(
          radius: 36,
          backgroundColor: const Color(0xFF1E293B),
          child: CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}