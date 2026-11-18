import 'package:flutter/material.dart';

/// Stellt nach einer Aktion die vorherige Scrollposition wieder her, falls
/// Fokus- oder Layoutänderungen während des Antippens die Ansicht verschieben.
void preserveScrollablePosition(BuildContext context, VoidCallback action) {
  final position = Scrollable.maybeOf(context)?.position;
  final offset = position?.pixels;

  action();
  FocusManager.instance.primaryFocus?.unfocus();

  if (position == null || offset == null) return;
  void restore() {
    if (!position.hasPixels) return;
    final target = offset
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if ((position.pixels - target).abs() > 0.5) {
      position.jumpTo(target);
    }
  }

  // Ein Chip kann erst nach dem aktuellen Frame Fokus anfordern. Deshalb
  // die Position nach zwei aufeinanderfolgenden Layoutdurchläufen wiederherstellen.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    restore();
    WidgetsBinding.instance.addPostFrameCallback((_) => restore());
  });
}
