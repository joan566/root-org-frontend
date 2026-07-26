import 'package:flutter/material.dart';

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Inicia en la esquina superior izquierda
    path.lineTo(0, size.height - 60);

    // Primera sección de la curva orgánica continua
    var firstControlPoint = Offset(size.width * 0.3, size.height + 10);
    var firstEndPoint = Offset(size.width * 0.6, size.height - 35);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    // Segunda sección que suaviza la salida hacia el extremo derecho
    var secondControlPoint = Offset(size.width * 0.85, size.height - 70);
    var secondEndPoint = Offset(size.width, size.height - 25);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    // Cierra el polígono en la esquina superior derecha
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}