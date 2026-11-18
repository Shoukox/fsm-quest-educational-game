import 'package:bachelor/core/services/local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lessonSkipServiceProvider = Provider(
  (ref) => LessonSkipService(LocalStorageService()),
);

/// Speichert pro Lektion, ob der einmalige direkte Testeinstieg verbraucht ist.
/// Der Verbrauch erfolgt vor dem Teststart und bleibt auch bei einem Abbruch bestehen.
class LessonSkipService {
  LessonSkipService(this.storage);
  final LocalStorageService storage;
  String _key(String lessonId) => 'lesson_test_shortcut_used.$lessonId';
  Future<bool> isAvailable(String lessonId) async =>
      !await storage.getBool(_key(lessonId));
  Future<bool> consume(String lessonId) async {
    if (!await isAvailable(lessonId)) return false;
    await storage.setBool(_key(lessonId), true);
    return true;
  }
}
