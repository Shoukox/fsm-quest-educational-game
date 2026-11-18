import 'package:bachelor/core/services/local_storage_service.dart';
import 'package:flutter/foundation.dart';

const developerUnlockAllLevelsKey = 'developer_unlock_all_levels';

/// Verwaltet die Entwicklerfreigabe aller Level; in Release-Builds bleibt sie aus.
class DeveloperAccessController extends ChangeNotifier {
  DeveloperAccessController._() {
    Future.microtask(load);
  }

  static final instance = DeveloperAccessController._();

  bool _unlockAllLevels = false;
  bool _hasLoaded = false;

  bool get unlockAllLevels => _unlockAllLevels;

  Future<void> setUnlockAllLevels(bool enabled) async {
    if (kReleaseMode) return;
    _unlockAllLevels = enabled;
    notifyListeners();
    try {
      await LocalStorageService().setBool(developerUnlockAllLevelsKey, enabled);
    } catch (_) {
      // Ohne verfügbaren Speicher bleibt die Auswahl im Arbeitsspeicher nutzbar.
    }
  }

  Future<void> load() async {
    if (_hasLoaded) return;
    if (kReleaseMode) {
      _hasLoaded = true;
      _unlockAllLevels = false;
      return;
    }
    try {
      _unlockAllLevels = await LocalStorageService().getBool(
        developerUnlockAllLevelsKey,
      );
    } catch (_) {
      _unlockAllLevels = false;
    }
    _hasLoaded = true;
    notifyListeners();
  }
}
