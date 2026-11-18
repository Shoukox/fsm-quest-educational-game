import 'package:bachelor/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Kreisförmiger Zustandsknoten, dessen Hintergrund den aktiven Simulationszustand markiert.
class StateNodeWidget extends StatelessWidget {
  const StateNodeWidget({
    required this.label,
    this.isActive = false,
    super.key,
  });

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? context.colors.secondary : context.colors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.text, width: 2),
      ),
      child: Text(label),
    );
  }
}
