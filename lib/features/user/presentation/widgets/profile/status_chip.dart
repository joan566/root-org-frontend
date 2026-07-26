import 'package:flutter/cupertino.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isActive = status.toLowerCase() == 'activo' || status.toLowerCase() == 'activa';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(6)
      ),
      child: Text(
          status,
          style: TextStyle(color: isActive ? const Color(0xFF15803D) : const Color(0xFFB45309), fontSize: 10, fontWeight: FontWeight.w700)
      ),
    );
  }
}