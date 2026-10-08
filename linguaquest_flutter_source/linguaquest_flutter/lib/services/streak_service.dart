import 'database_service.dart';

class StreakService {
  StreakService(this.database);
  final DatabaseService database;

  Future<int> recordLearningDay() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDay = await database.setting('last_learning_day');
    final summary = await database.summary();
    final current = summary['streak'] as int? ?? 0;
    if (lastDay == today) return current;
    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);
    final next = lastDay == yesterday ? current + 1 : 1;
    await database.updateStreak(next);
    await database.saveLastLearningDay(today);
    return next;
  }
}
