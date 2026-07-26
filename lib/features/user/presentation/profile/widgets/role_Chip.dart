import 'package:flutter/cupertino.dart';

class RoleChip extends StatelessWidget {
  final List<String> roles;
  const RoleChip({required this.roles});

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: roles.map((role) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(6)),
          child: Text(role, style: const TextStyle(color: Color(0xFF0369A1), fontSize: 10, fontWeight: FontWeight.w700)),
        );
      }).toList(),
    );
  }
}