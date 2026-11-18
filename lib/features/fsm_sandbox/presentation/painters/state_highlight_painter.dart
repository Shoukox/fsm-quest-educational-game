import 'package:flutter/material.dart';

/// Zeichnet eine kreisförmige Farbfläche zur Hervorhebung eines Zustands.
class StateHighlightPainter extends CustomPainter {
  const StateHighlightPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(size.center(Offset.zero), size.shortestSide / 2, paint);
  }

  @override
  bool shouldRepaint(covariant StateHighlightPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
