/// Beschreibt einen Erfolg mit Titel, Erläuterung und aktuellem Freischaltstatus.
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.isUnlocked = false,
  });

  final String id;
  final String title;
  final String description;
  final bool isUnlocked;
}
