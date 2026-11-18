/// Gemeinsame Eingabeprüfungen; reine Leerzeichen zählen nicht als Inhalt.
abstract final class Validators {
  static bool isNotBlank(String value) => value.trim().isNotEmpty;
}
