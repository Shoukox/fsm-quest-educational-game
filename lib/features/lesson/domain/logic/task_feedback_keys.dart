/// Leitet Übersetzungsschlüssel aus stabilen Aufgaben-IDs ab.
/// [correct] liefert die Begründung einer richtigen Antwort, [answer] einen Hinweis
/// zur gewählten Option und [wrong] einen ergänzenden Hinweis bei berechnetem Feedback.
abstract final class TaskFeedbackKeys {
  static String correct(String taskId) => 'feedback.$taskId.correct';

  static String answer(String taskId, String answerId) =>
      'feedback.$taskId.$answerId';

  static String wrong(String taskId) => 'feedback.$taskId.wrong';
}
