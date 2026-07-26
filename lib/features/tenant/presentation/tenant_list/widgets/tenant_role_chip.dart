import 'package:flutter/material.dart';

class TenantRoleChip extends StatelessWidget {
  final List<String> roles;
  const TenantRoleChip({super.key, required this.roles});

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: roles.map((role) {
        Color bg = const Color(0xFFF1F5F9);
        Color text = const Color(0xFF475569);

        switch (role.toLowerCase()) {
          case 'administrador':
            bg = const Color(0xFFE0F2FE);
            text = const Color(0xFF0369A1);
            break;
          case 'propietario':
            bg = const Color(0xFFD1FAE5);
            text = const Color(0xFF065F46);
            break;
          case 'consultor':
            bg = const Color(0xFFF3E8FF);
            text = const Color(0xFF7E22CE);
            break;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
          child: Text(role, style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.w600)),
        );
      }).toList(),
    );
  }
}
