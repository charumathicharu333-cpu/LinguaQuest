import 'database_service.dart';

abstract final class XPService {
  static const correctAnswer = 10;
  static const lessonComplete = 25;
  static const dailyQuest = 100;

  static Future<void> award(DatabaseService database, int amount) =>
      database.addXp(amount);
}
