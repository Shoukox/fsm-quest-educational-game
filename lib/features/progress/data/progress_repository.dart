import 'package:bachelor/core/services/database_service.dart';
import 'package:bachelor/features/progress/domain/models/user_progress.dart';

/// Stellt den gespeicherten Nutzerfortschritt über den Datenbankdienst bereit.
class ProgressRepository {
  ProgressRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  Future<UserProgress> getProgress() {
    return _databaseService.getUserProgress();
  }

  Future<void> saveProgress(UserProgress progress) {
    return _databaseService.saveUserProgress(progress);
  }
}
