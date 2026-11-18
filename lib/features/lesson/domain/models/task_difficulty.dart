/// Vier Schwierigkeitsstufen mit aufsteigender Nummer und eigenem Übersetzungsschlüssel.
enum TaskDifficulty {
  ss1,
  ss2,
  ss3,
  ss4;

  int get level => index + 1;

  String get localizationKey => 'taskDifficulty.$name';
}
