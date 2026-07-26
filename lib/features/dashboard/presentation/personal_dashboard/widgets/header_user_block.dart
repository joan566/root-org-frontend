import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class HeaderUserBlock extends StatelessWidget {
  final bool isScrolledDark;

  const HeaderUserBlock({required this.isScrolledDark});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textColor = isScrolledDark ? colors.textPrimary : Colors.white;
    final subColor = isScrolledDark ? colors.textSecondary : Colors.white.withOpacity(0.6);
    final avatarBorder = isScrolledDark ? colors.border : Colors.white24;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                      child: const Text('Hola, Joan'),
                    ),
                    const SizedBox(width: 6),
                    const Text('👋', style: TextStyle(fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: subColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  child: const Text(
                    'Bienvenido nuevamente. Administra tu cuenta y accede a tus organizaciones.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: avatarBorder,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.primary.withOpacity(0.2),
                  child: Text(
                    'JV',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: isScrolledDark ? Colors.white : colors.slateDark, width: 2.5),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}