import 'package:bachelor/core/services/database_factory_initializer.dart';
import 'package:bachelor/features/progress/domain/models/lesson_progress.dart';
import 'package:bachelor/features/progress/domain/models/user_progress.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// Bündelt SQLite-Zugriffe auf Profil, Lernfortschritt, Erfolge und Einstellungen.
class DatabaseService {
  DatabaseService._() {
    initializeFactory();
  }

  static bool _factoryInitialized = false;

  static void initializeFactory() {
    if (_factoryInitialized) return;
    initializeDatabaseFactory();
    _factoryInitialized = true;
  }

  static final DatabaseService instance = DatabaseService._();

  static const _databaseName = 'fsm_quest.db';
  static const _databaseVersion = 3;

  // Alle gleichzeitigen Zugriffe warten auf denselben Öffnungsvorgang,
  // damit vor dessen Abschluss keine zweite Verbindung angelegt wird.
  Database? _database;
  Future<Database>? _openFuture;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _openFuture ??= _openDatabase();
    return _openFuture!;
  }

  Future<Database> _openDatabase() async {
    final fullPath = kIsWeb
        ? _databaseName
        : path.join(await getDatabasesPath(), _databaseName);

    _database = await openDatabase(
      fullPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      onUpgrade: _onUpgrade,
      onOpen: _ensureSchema,
    );

    return _database!;
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createSchema(db);
    await _seedInitialData(db);
  }

  // Führt bei einer höheren Datenbankversion die nötigen Migrationen aus.
  // Einzelne Versionsschritte bleiben auch bei übersprungenen Updates erhalten.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE user_profile ADD COLUMN coins INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE lesson_progress ADD COLUMN stars INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 3) {
      await db.delete(
        'settings',
        where: 'key = ?',
        whereArgs: ['profile_birth_date'],
      );
    }
  }

  Future<void> _ensureSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createSchema(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        total_xp INTEGER NOT NULL DEFAULT 0,
        streak_days INTEGER NOT NULL DEFAULT 0,
        hearts INTEGER NOT NULL DEFAULT 5,
        gems INTEGER NOT NULL DEFAULT 0,
        coins INTEGER NOT NULL DEFAULT 0,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE lesson_progress (
        lesson_id TEXT PRIMARY KEY,
        is_unlocked INTEGER NOT NULL DEFAULT 0,
        is_completed INTEGER NOT NULL DEFAULT 0,
        best_score INTEGER NOT NULL DEFAULT 0,
        attempts INTEGER NOT NULL DEFAULT 0,
        stars INTEGER NOT NULL DEFAULT 0,
        last_played_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements (
        achievement_id TEXT PRIMARY KEY,
        is_unlocked INTEGER NOT NULL DEFAULT 0,
        unlocked_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedInitialData(DatabaseExecutor db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('user_profile', {
      'id': 1,
      'total_xp': 0,
      'streak_days': 0,
      'hearts': 5,
      'gems': 0,
      'coins': 0,
      'updated_at': now,
    });

    await db.insert('lesson_progress', {
      'lesson_id': 'intro',
      'is_unlocked': 1,
      'is_completed': 0,
      'best_score': 0,
      'attempts': 0,
      'stars': 0,
      'last_played_at': null,
    });
  }

  // ---------------------------------------------------------------------------
  // Nutzerfortschritt
  // ---------------------------------------------------------------------------

  Future<UserProgress> getUserProgress() async {
    final db = await database;

    final profileRows = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    // Ein fehlendes Profil einmalig anlegen und direkt erneut lesen.
    // So entsteht bei fehlgeschlagener Initialisierung keine Rekursion.
    if (profileRows.isEmpty) {
      await _seedInitialData(db);
      final seeded = await db.query(
        'user_profile',
        where: 'id = ?',
        whereArgs: [1],
        limit: 1,
      );
      if (seeded.isEmpty) {
        throw StateError('Failed to seed user_profile row.');
      }
      return _buildUserProgress(seeded.first, []);
    }

    final lessonRows = await db.query(
      'lesson_progress',
      orderBy: 'lesson_id ASC',
    );

    return _buildUserProgress(
      profileRows.first,
      lessonRows.map(_lessonProgressFromRow).toList(),
    );
  }

  UserProgress _buildUserProgress(
    Map<String, Object?> profile,
    List<LessonProgress> lessons,
  ) {
    return UserProgress(
      totalXp: profile['total_xp'] as int,
      streakDays: profile['streak_days'] as int,
      hearts: profile['hearts'] as int,
      gems: profile['gems'] as int,
      coins: profile['coins'] as int,
      lessons: lessons,
    );
  }

  /// Speichert Profildaten und die enthaltenen Lektionsstände in einer Transaktion.
  /// Herzen und Edelsteine werden dabei aus [progress] übernommen.
  Future<void> saveUserProgress(UserProgress progress) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      await txn.insert('user_profile', {
        'id': 1,
        'total_xp': progress.totalXp,
        'streak_days': progress.streakDays,
        'hearts': progress.hearts,
        'gems': progress.gems,
        'coins': progress.coins,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      for (final lesson in progress.lessons) {
        await txn.insert(
          'lesson_progress',
          _lessonProgressToRow(lesson),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Lektionsfortschritt
  // ---------------------------------------------------------------------------

  Future<List<LessonProgress>> getLessonProgress() async {
    final db = await database;
    final rows = await db.query('lesson_progress', orderBy: 'lesson_id ASC');
    return rows.map(_lessonProgressFromRow).toList();
  }

  Future<void> upsertLessonProgress(LessonProgress progress) async {
    final db = await database;
    await db.insert(
      'lesson_progress',
      _lessonProgressToRow(progress),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Speichert den Abschluss und vergibt die übergebenen Belohnungen atomar.
  /// Bisherige Bestwerte bleiben erhalten; jeder Aufruf zählt als weiterer Versuch.
  Future<void> completeLesson({
    required String lessonId,
    required int score,
    required int stars,
    required int earnedXp,
    required int earnedCoins,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      final existingLessonRows = await txn.query(
        'lesson_progress',
        where: 'lesson_id = ?',
        whereArgs: [lessonId],
        limit: 1,
      );

      final existingLesson = existingLessonRows.isEmpty
          ? null
          : _lessonProgressFromRow(existingLessonRows.first);
      final bestScore =
          existingLesson == null || score > existingLesson.bestScore
          ? score
          : existingLesson.bestScore;
      final bestStars = existingLesson == null || stars > existingLesson.stars
          ? stars
          : existingLesson.stars;

      await txn.insert('lesson_progress', {
        'lesson_id': lessonId,
        'is_unlocked': 1,
        'is_completed': 1,
        'best_score': bestScore,
        'attempts': (existingLesson?.attempts ?? 0) + 1,
        'stars': bestStars,
        'last_played_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      final profileRows = await txn.query(
        'user_profile',
        where: 'id = ?',
        whereArgs: [1],
        limit: 1,
      );

      if (profileRows.isEmpty) {
        await txn.insert('user_profile', {
          'id': 1,
          'total_xp': 0,
          'streak_days': 0,
          'hearts': 5,
          'gems': 0,
          'coins': 0,
          'updated_at': now,
        });
      }

      final profile = profileRows.isEmpty
          ? {
              'total_xp': 0,
              'streak_days': 0,
              'hearts': 5,
              'gems': 0,
              'coins': 0,
            }
          : profileRows.first;

      await txn.insert('user_profile', {
        'id': 1,
        'total_xp': (profile['total_xp'] as int) + earnedXp,
        'streak_days': (profile['streak_days'] as int) == 0
            ? 1
            : profile['streak_days'] as int,
        'hearts': profile['hearts'] as int,
        'gems': profile['gems'] as int,
        'coins': (profile['coins'] as int) + earnedCoins,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  /// Zieht Münzen nur bei ausreichendem Guthaben ab.
  /// Guthabenprüfung und Abbuchung erfolgen gemeinsam im selben SQL-Befehl.
  Future<bool> trySpendCoins(int amount) async {
    if (amount <= 0) return true;
    final db = await database;
    final updatedRows = await db.rawUpdate(
      'UPDATE user_profile '
      'SET coins = coins - ?, updated_at = ? '
      'WHERE id = 1 AND coins >= ?',
      [amount, DateTime.now().millisecondsSinceEpoch, amount],
    );
    return updatedRows > 0;
  }

  Future<void> resetFirstChapterProgress() async {
    await resetChapterProgress(
      lessonIds: const ['intro', 'states', 'transitions', 'chapter_test'],
      firstLessonId: 'intro',
    );
  }

  /// Entfernt die angegebenen Lektionsstände und schaltet die erste Lektion frei.
  Future<void> resetChapterProgress({
    required List<String> lessonIds,
    required String firstLessonId,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      if (lessonIds.isEmpty) return;
      await txn.delete(
        'lesson_progress',
        where:
            'lesson_id IN (${List.filled(lessonIds.length, '?').join(', ')})',
        whereArgs: lessonIds,
      );
      await txn.insert('lesson_progress', {
        'lesson_id': firstLessonId,
        'is_unlocked': 1,
        'is_completed': 0,
        'best_score': 0,
        'attempts': 0,
        'stars': 0,
        'last_played_at': null,
      });
    });
  }

  // ---------------------------------------------------------------------------
  // Erfolge
  // ---------------------------------------------------------------------------

  Future<void> unlockAchievement(String achievementId) async {
    final db = await database;
    await db.insert('achievements', {
      'achievement_id': achievementId,
      'is_unlocked': 1,
      'unlocked_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> isAchievementUnlocked(String achievementId) async {
    final db = await database;
    final rows = await db.query(
      'achievements',
      columns: ['is_unlocked'],
      where: 'achievement_id = ?',
      whereArgs: [achievementId],
      limit: 1,
    );

    return rows.isNotEmpty && rows.first['is_unlocked'] == 1;
  }

  // ---------------------------------------------------------------------------
  // Einstellungen
  // ---------------------------------------------------------------------------

  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query(
      'settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ---------------------------------------------------------------------------
  // Zurücksetzen
  // ---------------------------------------------------------------------------

  Future<void> resetUserData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('settings');
      await txn.delete('achievements');
      await txn.delete('lesson_progress');
      await txn.delete('user_profile');
      await _seedInitialData(txn);
    });
  }

  // ---------------------------------------------------------------------------
  // Zuordnung zwischen Datenbankzeilen und Modellen
  // ---------------------------------------------------------------------------

  LessonProgress _lessonProgressFromRow(Map<String, Object?> row) {
    return LessonProgress(
      lessonId: row['lesson_id'] as String,
      isUnlocked: row['is_unlocked'] == 1, // SQLite speichert boolesche Werte als 0 oder 1.
      isCompleted: row['is_completed'] == 1,
      bestScore: row['best_score'] as int,
      attempts: row['attempts'] as int, // Die gespeicherte Versuchszahl übernehmen.
      stars: row['stars'] as int,
    );
  }

  Map<String, Object?> _lessonProgressToRow(LessonProgress progress) {
    return {
      'lesson_id': progress.lessonId,
      'is_unlocked': progress.isUnlocked ? 1 : 0, // Den tatsächlichen Freigabestatus speichern.
      'is_completed': progress.isCompleted ? 1 : 0,
      'best_score': progress.bestScore,
      'attempts': progress.attempts, // Die Versuchszahl beim Speichern erhalten.
      'stars': progress.stars,
      'last_played_at': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
