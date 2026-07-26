import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';

class InteractiveActionButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isHighlight;
  final VoidCallback onTap;

  const InteractiveActionButton({
    required this.icon,
    required this.title,
    required this.isHighlight,
    required this.onTap,
  });

  @override
  State<InteractiveActionButton> createState() => _InteractiveActionButtonState();
}

class _InteractiveActionButtonState extends State<InteractiveActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: widget.isHighlight
                ? (_isHovered ? colors.primaryDark : colors.primary)
                : (_isHovered ? colors.primaryLight.withOpacity(0.5) : colors.surface),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isHighlight ? Colors.transparent : (_isHovered ? colors.primary : colors.border),
              width: 1,
            ),
            boxShadow: _isHovered ? colors.subtleShadow() : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              splashColor: widget.isHighlight ? Colors.white24 : colors.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(widget.icon, size: 22, color: widget.isHighlight ? Colors.white : colors.textPrimary),
                    Text(
                      widget.title,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: widget.isHighlight ? Colors.white : colors.textPrimary,
                          letterSpacing: -0.3
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}