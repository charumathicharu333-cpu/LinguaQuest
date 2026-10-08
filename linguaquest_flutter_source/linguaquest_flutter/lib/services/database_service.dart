import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService({this.pathOverride});

  final String? pathOverride;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final root =
        pathOverride ?? path.join(await getDatabasesPath(), 'linguaquest.db');
    _database = await openDatabase(
      root,
      version: 1,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) => _createSchema(db),
    );
    await _seed(_database!);
    return _database!;
  }

  Future<void> _createSchema(Database db) async {
    const statements = [
      'CREATE TABLE users (id TEXT PRIMARY KEY, created_at TEXT NOT NULL, xp INTEGER NOT NULL DEFAULT 0, streak INTEGER NOT NULL DEFAULT 0)',
      'CREATE TABLE age_profiles (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id TEXT NOT NULL UNIQUE REFERENCES users(id), age_group TEXT NOT NULL)',
      'CREATE TABLE languages (code TEXT PRIMARY KEY, name TEXT NOT NULL, flag TEXT NOT NULL, is_active INTEGER NOT NULL DEFAULT 1)',
      'CREATE TABLE categories (id TEXT PRIMARY KEY, name TEXT NOT NULL, emoji TEXT NOT NULL)',
      'CREATE TABLE worlds (id TEXT PRIMARY KEY, name TEXT NOT NULL, emoji TEXT NOT NULL, required_xp INTEGER NOT NULL)',
      'CREATE TABLE levels (id TEXT PRIMARY KEY, world_id TEXT NOT NULL REFERENCES worlds(id), name TEXT NOT NULL, sort_order INTEGER NOT NULL)',
      'CREATE TABLE lessons (id TEXT PRIMARY KEY, language_code TEXT REFERENCES languages(code), level_id TEXT REFERENCES levels(id), title TEXT NOT NULL, topic TEXT NOT NULL, sort_order INTEGER NOT NULL)',
      'CREATE TABLE words (id INTEGER PRIMARY KEY AUTOINCREMENT, lesson_id TEXT NOT NULL REFERENCES lessons(id), source TEXT NOT NULL, translation TEXT NOT NULL)',
      'CREATE TABLE questions (id TEXT PRIMARY KEY, category_id TEXT NOT NULL REFERENCES categories(id), prompt TEXT NOT NULL, explanation TEXT NOT NULL)',
      'CREATE TABLE answers (id INTEGER PRIMARY KEY AUTOINCREMENT, question_id TEXT NOT NULL REFERENCES questions(id), answer_text TEXT NOT NULL, is_correct INTEGER NOT NULL)',
      'CREATE TABLE user_progress (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id TEXT NOT NULL REFERENCES users(id), activity_id TEXT NOT NULL, activity_type TEXT NOT NULL, completed INTEGER NOT NULL DEFAULT 0, correct_count INTEGER NOT NULL DEFAULT 0, attempts INTEGER NOT NULL DEFAULT 0, updated_at TEXT NOT NULL, UNIQUE(user_id, activity_id, activity_type))',
      'CREATE TABLE achievements (id TEXT PRIMARY KEY, title TEXT NOT NULL, description TEXT NOT NULL, emoji TEXT NOT NULL, threshold INTEGER NOT NULL)',
      'CREATE TABLE user_achievements (user_id TEXT NOT NULL REFERENCES users(id), achievement_id TEXT NOT NULL REFERENCES achievements(id), unlocked_at TEXT NOT NULL, PRIMARY KEY(user_id, achievement_id))',
      'CREATE TABLE daily_challenges (id TEXT PRIMARY KEY, challenge_date TEXT NOT NULL, title TEXT NOT NULL, target INTEGER NOT NULL, progress INTEGER NOT NULL DEFAULT 0, reward_xp INTEGER NOT NULL DEFAULT 100, completed INTEGER NOT NULL DEFAULT 0)',
      'CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
      'CREATE TABLE content_packs (id TEXT PRIMARY KEY, title TEXT NOT NULL, version INTEGER NOT NULL, bundled INTEGER NOT NULL DEFAULT 1)',
      'CREATE INDEX idx_questions_category ON questions(category_id)',
      'CREATE INDEX idx_lessons_language ON lessons(language_code)',
      'CREATE INDEX idx_progress_user ON user_progress(user_id, activity_type)',
      'CREATE INDEX idx_words_lesson ON words(lesson_id)',
    ];
    for (final statement in statements) {
      await db.execute(statement);
    }
  }

  Future<void> _seed(Database db) async {
    final existing = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM users')) ??
        0;
    if (existing > 0) return;
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.insert('users',
          {'id': 'local-player', 'created_at': now, 'xp': 0, 'streak': 0});
      await txn
          .insert('settings', {'key': 'onboarding_complete', 'value': 'false'});
      await txn.insert('settings', {'key': 'age_group', 'value': '11-14'});
      await txn.insert('settings', {'key': 'language', 'value': 'en'});
      const categories = [
        ['science', 'Science', '🧪'],
        ['geography', 'Geography', '🌍'],
        ['gk', 'General Knowledge', '✨'],
        ['logic', 'Logic', '🧩'],
      ];
      for (final row in categories) {
        await txn.insert(
            'categories', {'id': row[0], 'name': row[1], 'emoji': row[2]});
      }
      const worlds = [
        ['welcome', 'Welcome Village', '🏡', 0],
        ['vocabulary', 'Vocabulary Village', '📚', 100],
        ['garden', 'Grammar Garden', '🌱', 200],
        ['city', 'Conversation City', '🏙️', 300],
        ['lab', 'Science Lab', '🧪', 400],
        ['space', 'Space Zone', '🚀', 500],
        ['nature', 'Nature Park', '🌳', 600],
        ['geography', 'Geography World', '🌍', 700],
        ['history', 'History Land', '🏛️', 800],
        ['technology', 'Technology Hub', '💻', 900],
        ['castle', 'Knowledge Castle', '🏰', 1000],
      ];
      for (final row in worlds) {
        await txn.insert('worlds', {
          'id': row[0],
          'name': row[1],
          'emoji': row[2],
          'required_xp': row[3]
        });
        await txn.insert('levels', {
          'id': '${row[0]}-start',
          'world_id': row[0],
          'name': 'First steps',
          'sort_order': 0
        });
      }
      const languages = [
        ['en', 'English', '🇬🇧'],
        ['hi', 'Hindi', '🇮🇳'],
        ['ja', 'Japanese', '🇯🇵'],
      ];
      for (final row in languages) {
        await txn.insert(
            'languages', {'code': row[0], 'name': row[1], 'flag': row[2]});
        final raw = await rootBundle.loadString(
            'assets/data/${row[0] == 'en' ? 'english' : row[0] == 'hi' ? 'hindi' : 'japanese'}.json');
        final pack = jsonDecode(raw) as Map<String, dynamic>;
        final lessonRows = pack['lessons'] as List<dynamic>;
        await txn.insert('content_packs',
            {'id': 'language-${row[0]}', 'title': row[1], 'version': 1});
        for (var i = 0; i < lessonRows.length; i++) {
          final lesson = lessonRows[i] as Map<String, dynamic>;
          final lessonId = '${row[0]}-$i';
          await txn.insert('lessons', {
            'id': lessonId,
            'language_code': row[0],
            'level_id': 'vocabulary-start',
            'title': lesson['title'],
            'topic': lesson['topic'],
            'sort_order': i
          });
          for (final pair in lesson['words'] as List<dynamic>) {
            await txn.insert('words', {
              'lesson_id': lessonId,
              'source': pair[0],
              'translation': pair[1]
            });
          }
        }
      }
      const questionFiles = {
        'science': 'science',
        'geography': 'geography',
        'gk': 'gk',
        'logic': 'logic'
      };
      for (final entry in questionFiles.entries) {
        final decoded = jsonDecode(
                await rootBundle.loadString('assets/data/${entry.value}.json'))
            as Map<String, dynamic>;
        await txn.insert('content_packs',
            {'id': entry.key, 'title': decoded['category'], 'version': 1});
        for (final item in decoded['questions'] as List<dynamic>) {
          final q = item as Map<String, dynamic>;
          await txn.insert('questions', {
            'id': q['id'],
            'category_id': entry.key,
            'prompt': q['prompt'],
            'explanation': q['explanation']
          });
          final choices = q['choices'] as List<dynamic>;
          for (var i = 0; i < choices.length; i++) {
            await txn.insert('answers', {
              'question_id': q['id'],
              'answer_text': choices[i],
              'is_correct': i == q['answer'] ? 1 : 0
            });
          }
        }
      }
      const badges = [
        [
          'first-steps',
          'First Footprints',
          'Finish your first lesson',
          '👣',
          1
        ],
        [
          'curious-mind',
          'Curious Mind',
          'Answer ten questions correctly',
          '🔎',
          10
        ],
        ['world-wanderer', 'World Wanderer', 'Earn 250 XP', '🧭', 250],
      ];
      for (final badge in badges) {
        await txn.insert('achievements', {
          'id': badge[0],
          'title': badge[1],
          'description': badge[2],
          'emoji': badge[3],
          'threshold': badge[4]
        });
      }
      final day = DateTime.now().toIso8601String().substring(0, 10);
      await txn.insert('daily_challenges', {
        'id': 'daily-$day',
        'challenge_date': day,
        'title': 'Complete one short lesson',
        'target': 1
      });
    });
  }

  Future<String> setting(String key, [String fallback = '']) async {
    final db = await database;
    final rows = await db.query('settings',
        columns: ['value'], where: 'key = ?', whereArgs: [key], limit: 1);
    return rows.isEmpty ? fallback : rows.first['value']! as String;
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, Object?>> summary() async {
    final db = await database;
    final user =
        (await db.query('users', where: 'id = ?', whereArgs: ['local-player']))
            .first;
    final progress = await db.rawQuery(
        "SELECT COUNT(CASE WHEN completed = 1 THEN 1 END) AS lessons, SUM(correct_count) AS correct, SUM(attempts) AS attempts FROM user_progress WHERE user_id = 'local-player'");
    final badges = await db.rawQuery(
        "SELECT COUNT(*) AS count FROM user_achievements WHERE user_id = 'local-player'");
    return {...user, ...progress.first, 'badges': badges.first['count'] ?? 0};
  }

  Future<void> recordProgress(
      {required String activityId,
      required String type,
      required bool correct,
      bool complete = false}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.rawInsert(
        '''INSERT INTO user_progress(user_id, activity_id, activity_type, completed, correct_count, attempts, updated_at)
      VALUES('local-player', ?, ?, ?, ?, 1, ?)
      ON CONFLICT(user_id, activity_id, activity_type) DO UPDATE SET
      completed = MAX(completed, excluded.completed), correct_count = correct_count + excluded.correct_count,
      attempts = attempts + 1, updated_at = excluded.updated_at''',
        [activityId, type, complete ? 1 : 0, correct ? 1 : 0, now]);
  }

  Future<void> addXp(int amount) async {
    final db = await database;
    await db.rawUpdate(
        "UPDATE users SET xp = xp + ? WHERE id = 'local-player'", [amount]);
  }

  Future<void> completeDailyChallenge() async {
    final db = await database;
    final day = DateTime.now().toIso8601String().substring(0, 10);
    await db.insert(
        'daily_challenges',
        {
          'id': 'daily-$day',
          'challenge_date': day,
          'title': 'Complete one short lesson',
          'target': 1
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.update('daily_challenges', {'progress': 1, 'completed': 1},
        where: 'challenge_date = ?', whereArgs: [day]);
  }

  Future<int> ensureDailyChallenge() async {
    final db = await database;
    final day = DateTime.now().toIso8601String().substring(0, 10);
    await db.insert(
        'daily_challenges',
        {
          'id': 'daily-$day',
          'challenge_date': day,
          'title': 'Complete one short lesson',
          'target': 1
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
    final rows = await db.query('daily_challenges',
        columns: ['completed'], where: 'challenge_date = ?', whereArgs: [day]);
    return rows.first['completed'] as int? ?? 0;
  }

  Future<bool> hasCompletedLesson(String lessonId) async {
    final db = await database;
    final rows = await db.query('user_progress',
        columns: ['completed'],
        where: "user_id = ? AND activity_id = ? AND activity_type = 'lesson'",
        whereArgs: ['local-player', lessonId]);
    return rows.isNotEmpty && rows.first['completed'] == 1;
  }

  Future<void> updateStreak(int streak) async {
    final db = await database;
    await db.rawUpdate(
        "UPDATE users SET streak = ? WHERE id = 'local-player'", [streak]);
  }

  Future<void> saveLastLearningDay(String date) =>
      saveSetting('last_learning_day', date);

  Future<void> unlockBadge(String id) async {
    final db = await database;
    await db.insert(
        'user_achievements',
        {
          'user_id': 'local-player',
          'achievement_id': id,
          'unlocked_at': DateTime.now().toIso8601String()
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Map<String, Object?>>> achievements() async {
    final db = await database;
    return db.rawQuery(
        '''SELECT a.*, CASE WHEN ua.user_id IS NULL THEN 0 ELSE 1 END AS unlocked
      FROM achievements a LEFT JOIN user_achievements ua ON a.id = ua.achievement_id AND ua.user_id = 'local-player' ORDER BY a.threshold''');
  }

  Future<List<Map<String, Object?>>> lessonWords(
      String language, String lessonId) async {
    final db = await database;
    return db.rawQuery(
        '''SELECT w.* FROM words w JOIN lessons l ON l.id = w.lesson_id
      WHERE l.language_code = ? AND l.id = ? ORDER BY w.id''',
        [language, lessonId]);
  }
}
