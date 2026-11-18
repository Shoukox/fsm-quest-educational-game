import 'package:flutter/services.dart';

/// Bündelt haptische Rückmeldungen für Interaktionen in der App.
/// Fehlende oder abgelehnte Plattformunterstützung darf die Aktion nicht verhindern.
class AppHaptics {
  AppHaptics._();

  /// Leichter Impuls für gewöhnliche Schaltflächen und Navigation.
  static Future<void> button() => _perform(HapticFeedback.lightImpact);

  /// Dezenter Impuls beim Ändern einer Auswahl oder eines Modus.
  static Future<void> selection() => _perform(HapticFeedback.selectionClick);

  /// Spürbare Bestätigung einer erfolgreichen Spielaktion.
  static Future<void> success() => _perform(HapticFeedback.mediumImpact);

  /// Spürbare Rückmeldung beim Anfordern eines Hinweises.
  static Future<void> hint() => _perform(HapticFeedback.mediumImpact);

  /// Spürbare Rückmeldung bei einer Maskottchen-Nachricht über der Lektion.
  static Future<void> mascotMessage() => _perform(HapticFeedback.mediumImpact);

  /// Starker Impuls bei Fehlern oder Aktionen, die Aufmerksamkeit erfordern.
  static Future<void> warning() => _perform(HapticFeedback.heavyImpact);

  /// Ergänzt einen Schaltflächen-Callback um den üblichen leichten Impuls.
  static VoidCallback? wrapButton(VoidCallback? callback) {
    if (callback == null) return null;
    return () {
      button();
      callback();
    };
  }

  /// Ergänzt einen Auswahl-Callback um einen dezenten Impuls.
  static ValueChanged<T>? wrapSelection<T>(ValueChanged<T>? callback) {
    if (callback == null) return null;
    return (value) {
      selection();
      callback(value);
    };
  }

  static Future<void> _perform(Future<void> Function() feedback) async {
    try {
      await feedback();
    } on MissingPluginException {
      // Haptische Rückmeldung ist nicht auf jeder Plattform verfügbar.
    } on PlatformException {
      // Die Plattform kann eine haptische Rückmeldung ablehnen.
    }
  }
}
