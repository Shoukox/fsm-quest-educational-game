/// Ergebnis einer Antwortprüfung mit Korrektheitswert, Anzeigetext und vorgesehenen Erfahrungspunkten.
class AnswerResult {
  const AnswerResult({
    required this.isCorrect,
    required this.message,
    this.xp = 0,
  });

  final bool isCorrect;
  final String message;
  final int xp;
}
