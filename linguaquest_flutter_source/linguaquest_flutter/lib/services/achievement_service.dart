import 'database_service.dart';

class AchievementService {
  AchievementService(this.database);
  final DatabaseService database;

  Future<int> refresh(
      {required int xp,
      required int correctAnswers,
      bool lessonCompleted = false}) async {
    if (lessonCompleted) await database.unlockBadge('first-steps');
    if (correctAnswers >= 10) await database.unlockBadge('curious-mind');
    if (xp >= 250) await database.unlockBadge('world-wanderer');
    return (await database.achievements())
        .where((row) => row['unlocked'] == 1)
        .length;
  }
}
