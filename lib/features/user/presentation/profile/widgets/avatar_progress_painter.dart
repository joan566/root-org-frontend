import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AvatarProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  AvatarProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paintBase = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final paintProgress = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 2;

    canvas.drawCircle(center, radius, paintBase);
    double angle = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, angle, false, paintProgress);
  }

  @override
  bool shouldRepaint(covariant AvatarProgressPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.color != color;
}