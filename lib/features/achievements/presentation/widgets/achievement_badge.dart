import 'package:bachelor/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Zeigt einen Erfolg als Chip mit Pokal oder Sperrsymbol entsprechend seinem Status.
class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    required this.title,
    this.isUnlocked = false,
    super.key,
  });

  final String title;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        isUnlocked ? Icons.emoji_events : Icons.lock,
        color: isUnlocked ? context.colors.warning : context.colors.mutedText,
      ),
      label: Text(title),
    );
  }
}
