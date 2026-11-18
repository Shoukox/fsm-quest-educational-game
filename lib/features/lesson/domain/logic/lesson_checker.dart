import 'package:bachelor/app/localization/app_localizations.dart';
import 'package:bachelor/features/lesson/domain/logic/task_feedback_keys.dart';
import 'package:bachelor/features/lesson/domain/models/answer_result.dart';
import 'package:bachelor/features/lesson/domain/models/lesson_task.dart';

/// Bewertet einfache Auswahlantworten und ergänzt passende übersetzte Rückmeldungen.
class LessonChecker {
  const LessonChecker();

  AnswerResult checkAnswer(
    LessonTask task,
    String answerId,
    AppLocalizations l10n,
  ) {
    final isCorrect = task.correctAnswerId == answerId;

    return AnswerResult(
      isCorrect: isCorrect,
      message: isCorrect
          ? correctMessage(task, l10n)
          : wrongMessage(
              l10n,
              task.feedbackByAnswer[answerId] ??
                  TaskFeedbackKeys.answer(task.id, answerId),
              fallback: l10n.t(
                'lesson.genericWrong',
                args: {'selected': l10n.t(answerId)},
              ),
            ),
      xp: isCorrect ? 10 : 0,
    );
  }

  /// Bestätigt eine richtige Antwort und ergänzt eine Begründung, sofern vorhanden.
  static String correctMessage(LessonTask task, AppLocalizations l10n) {
    final reasonKey = TaskFeedbackKeys.correct(task.id);
    return l10n.has(reasonKey)
        ? l10n.t(
            'lesson.correctWithReason',
            args: {'reason': l10n.t(reasonKey)},
          )
        : l10n.t('lesson.correct');
  }

  /// Nutzt vorhandenes Aufgabenfeedback, sonst [fallback] oder den Standardhinweis.
  static String wrongMessage(
    AppLocalizations l10n,
    String? key, {
    String? fallback,
  }) {
    if (key != null && l10n.has(key)) return l10n.t(key);
    return fallback ?? l10n.t('lesson.taskWrong');
  }
}
