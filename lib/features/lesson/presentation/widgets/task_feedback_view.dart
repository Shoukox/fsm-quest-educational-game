import 'package:flutter/material.dart';
import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/app/theme/app_colors.dart';
import 'package:bachelor/features/lesson/domain/models/task_feedback.dart';

/// Übersetzt strukturierte Bewertungsbefunde und zeigt sie als einzelne Fehlermeldungen.
/// Die Semantik markiert neue Hinweise als Live-Region für assistive Ausgaben.
class TaskFeedbackView extends StatelessWidget {
  const TaskFeedbackView({required this.feedback, super.key});
  final StructuredTaskFeedback feedback;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final issue in feedback.issues)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Semantics(
            liveRegion: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  color: context.colors.danger,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.t(
                      issue.localizationKey ?? 'lesson.taskWrong',
                      args: {
                        for (final entry in issue.args.entries)
                          entry.key: issue.localizedArgs.contains(entry.key)
                              ? context.l10n.t(entry.value)
                              : entry.value,
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
