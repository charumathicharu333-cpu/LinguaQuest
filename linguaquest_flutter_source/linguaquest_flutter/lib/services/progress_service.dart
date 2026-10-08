import '../models/quest_models.dart';
import 'xp_service.dart';

abstract final class ProgressService {
  static int xpForCorrectAnswer({int streakBonus = 0}) =>
      XPService.correctAnswer + streakBonus;

  static int levelForXp(int xp) => (xp ~/ 250) + 1;

  static double levelProgress(int xp) => (xp % 250) / 250;

  static bool isCorrect(QuestQuestion question, int selectedIndex) =>
      question.isCorrect(selectedIndex);

  static bool isWorldUnlocked(int index, int xp) =>
      index == 0 || xp >= (index * 100);
}
