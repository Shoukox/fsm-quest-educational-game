import 'package:flutter/material.dart';

/// Zeichnet eine einfache Verbindungslinie diagonal durch die verfügbare Fläche.
class TransitionPainter extends CustomPainter {
  const TransitionPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant TransitionPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
