import 'package:bachelor/core/widgets/app_progress_bar.dart';
import 'package:flutter/material.dart';

/// Stellt den bereits normierten Erfahrungspunkte-Anteil mit dem gemeinsamen Fortschrittsbalken dar.
class XpBar extends StatelessWidget {
  const XpBar({required this.value, super.key});

  final double value;

  @override
  Widget build(BuildContext context) {
    return AppProgressBar(value: value);
  }
}
