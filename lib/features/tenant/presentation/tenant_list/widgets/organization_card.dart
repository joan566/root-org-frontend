import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:savings_api_frontend/core/design_system/colors/app_colors.dart';
import '../../../../auth/domain/entities/user_tenant.dart';
import 'tenant_role_chip.dart';
import 'tenant_status_chip.dart';

class OrganizationCard extends StatefulWidget {
  final UserTenant org;
  final bool isRecent;
  final bool isOnlyOne;
  final VoidCallback onTap;

  const OrganizationCard({
    super.key,
    required this.org,
    required this.isRecent,
    required this.isOnlyOne,
    required this.onTap,
  });

  @override
  State<OrganizationCard> createState() => _OrganizationCardState();
}

class _OrganizationCardState extends State<OrganizationCard> {
  bool _isPressed = false;

  String _getInitials(String name) {
    if (name.isEmpty) return 'OR';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, math.min(2, name.length)).toUpperCase();
  }

  Color _getDeterministicColor(String name) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final String initials = _getInitials(widget.org.tenant.name);
    final Color brandColor = _getDeterministicColor(widget.org.tenant.name);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(22),
            boxShadow: colors.subtleShadow(),
            border: Border.all(
              color: widget.isRecent ? colors.primary.withOpacity(0.5) : colors.border,
              width: widget.isRecent ? 1.5 : 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              onTap: widget.onTap,
              splashColor: colors.primary.withOpacity(0.04),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isRecent)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _TagBadge(
                          text: 'Última utilizada',
                          icon: Icons.star_rounded,
                          isPrimary: true,
                        ),
                      )
                    else if (widget.isOnlyOne)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _TagBadge(
                          text: 'Organización única',
                          icon: Icons.shield_outlined,
                          isPrimary: false,
                        ),
                      ),

                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: brandColor.withOpacity(0.1),
                          child: Text(
                            initials,
                            style: TextStyle(color: brandColor, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.org.tenant.name,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary, letterSpacing: -0.3),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  TenantRoleChip(roles: widget.org.roles),
                                  const SizedBox(width: 8),
                                  TenantStatusChip(status: widget.org.status),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(color: colors.border, height: 1),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 12, color: colors.textSecondary),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Último acceso reciente',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11, color: colors.textSecondary, fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Entrar', style: TextStyle(color: colors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 2),
                            Icon(Icons.arrow_forward_rounded, size: 14, color: colors.primary),
                          ],
                        )
                      ],
                    )
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

class _TagBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isPrimary;

  const _TagBadge({required this.text, required this.icon, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary ? colors.primary.withOpacity(0.1) : const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isPrimary ? colors.primary : const Color(0xFF0369A1)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isPrimary ? colors.primary : const Color(0xFF0369A1)),
          ),
        ],
      ),
    );
  }
}
