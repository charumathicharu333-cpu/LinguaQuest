import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:linguaquest/services/app_state.dart';
import 'package:linguaquest/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('creates the offline schema and seeds all 80 knowledge questions',
      () async {
    final service = DatabaseService(pathOverride: ':memory:');
    final db = await service.database;
    expect(
        Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM questions')),
        80);
    expect(
        Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM languages')),
        3);
    expect(
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM worlds')),
        11);
    expect(await service.setting('onboarding_complete'), 'false');
    await db.close();
  });

  test('persists answer progress and XP in SQLite', () async {
    final service = DatabaseService(pathOverride: ':memory:');
    await service.database;
    await service.recordProgress(
        activityId: 'science-1', type: 'question', correct: true);
    await service.addXp(10);
    final summary = await service.summary();
    expect(summary['xp'], 10);
    expect(summary['correct'], 1);
    expect(summary['attempts'], 1);
    await (await service.database).close();
  });

  test('completes a lesson once and unlocks its first achievement', () async {
    final state = AppState(DatabaseService(pathOverride: ':memory:'));
    await state.initialize();
    await state.completeLesson('en-0');
    expect(state.xp, 125);
    expect(state.lessonsCompleted, 1);
    expect(state.dailyQuestComplete, isTrue);
    expect(state.badges, 1);
    await state.completeLesson('en-0');
    expect(state.xp, 125);
    expect(state.lessonsCompleted, 1);
  });
}
