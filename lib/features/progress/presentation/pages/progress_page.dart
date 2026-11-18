import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_text_styles.dart';
import 'package:bachelor/core/services/database_service.dart';
import 'package:bachelor/features/progress/domain/models/user_progress.dart';
import 'package:bachelor/features/progress/presentation/widgets/streak_widget.dart';
import 'package:bachelor/features/progress/presentation/widgets/xp_bar.dart';
import 'package:flutter/material.dart';

/// Zeigt Erfahrungspunkte, Lernserie und abgeschlossene Lektionen aus dem gespeicherten Fortschritt.
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadProgress(),
      builder: (context, snapshot) {
        final progress = snapshot.data;
        final totalXp = progress?.totalXp ?? 0;
        final streakDays = progress?.streakDays ?? 0;
        final completedLessons =
            progress?.lessons.where((lesson) => lesson.isCompleted).length ?? 0;
        final l10n = context.l10n;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.t('progress.title'), style: context.textStyles.title),
              const SizedBox(height: 16),
              XpBar(value: (totalXp / 100).clamp(0, 1).toDouble()),
              const SizedBox(height: 8),
              Text(
                l10n.t('progress.xp', args: {'xp': totalXp}),
                style: context.textStyles.caption,
              ),
              const SizedBox(height: 16),
              StreakWidget(days: streakDays),
              const SizedBox(height: 16),
              Text(
                l10n.t(
                  'progress.solvedTasks',
                  args: {'count': completedLessons},
                ),
                style: context.textStyles.body,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<UserProgress?> _loadProgress() async {
    try {
      return await DatabaseService.instance.getUserProgress();
    } catch (_) {
      return null;
    }
  }
}
