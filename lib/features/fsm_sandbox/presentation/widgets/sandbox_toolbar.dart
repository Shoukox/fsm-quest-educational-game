import 'package:bachelor/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Zeigt eine kompakte Symbolleiste; diese Darstellung verdrahtet selbst keine Aktionen.
class SandboxToolbar extends StatelessWidget {
  const SandboxToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(bottom: BorderSide(color: context.colors.border)),
      ),
      child: const Row(
        children: [
          Icon(Icons.add_circle_outline),
          SizedBox(width: 12),
          Icon(Icons.arrow_forward),
          SizedBox(width: 12),
          Icon(Icons.play_arrow),
        ],
      ),
    );
  }
}
