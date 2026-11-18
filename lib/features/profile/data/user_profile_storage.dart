import 'package:bachelor/core/services/local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileStorageProvider = Provider<UserProfileStorage>((ref) {
  return UserProfileStorage();
});

/// Speichert Profilangaben, Einführungsstatus und kosmetische Gegenstände lokal.
class UserProfileStorage {
  UserProfileStorage({LocalStorageService? storage})
    : _storage = storage ?? LocalStorageService();

  static const onboardingCompletedKey = 'profile_onboarding_completed';
  // Der gespeicherte Schlüssel bleibt stabil, damit vorhandene Benutzernamen
  // trotz geänderter Bezeichnung in der Oberfläche erhalten bleiben.
  static const nameKey = 'profile_name';
  static const mascotIntroSeenKey = 'mascot_intro_seen';
  static const chapter1SkippedKey = 'chapter1_skipped';
  static const chapter1EntryChoiceResolvedKey =
      'chapter1_entry_choice_resolved';
  static const ownedCosmeticsKey = 'profile_owned_cosmetics';
  static const equippedCosmeticKey = 'profile_equipped_cosmetic';

  final LocalStorageService _storage;

  Future<bool> isOnboardingCompleted() {
    return _storage.getBool(onboardingCompletedKey);
  }

  Future<String?> getName() {
    return _storage.getString(nameKey);
  }

  Future<Set<String>> getOwnedCosmetics() async {
    final value = await _storage.getString(ownedCosmeticsKey);
    if (value == null || value.trim().isEmpty) return <String>{};
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();
  }

  Future<void> addOwnedCosmetic(String id) async {
    final owned = await getOwnedCosmetics();
    owned.add(id);
    await _storage.setString(ownedCosmeticsKey, _serialize(owned));
  }

  Future<String?> getEquippedCosmetic() async {
    final value = await _storage.getString(equippedCosmeticKey);
    return value?.trim().isEmpty == true ? null : value;
  }

  Future<void> setEquippedCosmetic(String? id) async {
    if (id == null || id.trim().isEmpty) {
      await _storage.setString(equippedCosmeticKey, '');
      return;
    }
    await _storage.setString(equippedCosmeticKey, id.trim());
  }

  Future<bool> hasSeenMascotIntro() {
    return _storage.getBool(mascotIntroSeenKey);
  }

  Future<void> setMascotIntroSeen() {
    return _storage.setBool(mascotIntroSeenKey, true);
  }

  Future<bool> hasChapter1Skipped() {
    return _storage.getBool(chapter1SkippedKey);
  }

  Future<void> setChapter1Skipped(bool skipped) {
    return _storage.setBool(chapter1SkippedKey, skipped);
  }

  Future<bool> hasChapter1EntryChoiceResolved() {
    return _storage.getBool(chapter1EntryChoiceResolvedKey);
  }

  Future<void> setChapter1EntryChoiceResolved() {
    return _storage.setBool(chapter1EntryChoiceResolvedKey, true);
  }

  Future<void> saveProfile({required String name}) async {
    await _storage.setString(nameKey, name.trim());
    await _storage.setBool(onboardingCompletedKey, true);
  }

  // Sortieren erzeugt unabhängig von der Einfügereihenfolge dieselbe Speicherform.
  String _serialize(Set<String> values) {
    final sorted = values.toList()..sort();
    return sorted.join(',');
  }
}
