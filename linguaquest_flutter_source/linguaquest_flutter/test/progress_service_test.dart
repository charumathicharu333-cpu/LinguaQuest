import 'package:flutter_test/flutter_test.dart';
import 'package:linguaquest/models/quest_models.dart';
import 'package:linguaquest/services/progress_service.dart';
import 'package:linguaquest/services/xp_service.dart';

void main() {
  group('XP and progress rules', () {
    test('awards the intended values for a correct answer', () {
      expect(XPService.correctAnswer, 10);
      expect(ProgressService.xpForCorrectAnswer(), 10);
      expect(ProgressService.xpForCorrectAnswer(streakBonus: 2), 12);
    });

    test('converts XP into levels and a level progress fraction', () {
      expect(ProgressService.levelForXp(0), 1);
      expect(ProgressService.levelForXp(250), 2);
      expect(ProgressService.levelProgress(125), .5);
    });

    test('unlocks map locations progressively', () {
      expect(ProgressService.isWorldUnlocked(0, 0), isTrue);
      expect(ProgressService.isWorldUnlocked(3, 299), isFalse);
      expect(ProgressService.isWorldUnlocked(3, 300), isTrue);
    });
  });

  test('validates quiz choices without throwing on a wrong answer', () {
    const question = QuestQuestion(
        id: 'unit',
        category: 'Logic',
        prompt: '2 + 2?',
        choices: ['3', '4'],
        answerIndex: 1,
        explanation: 'Two pairs make four.');
    expect(question.isCorrect(1), isTrue);
    expect(ProgressService.isCorrect(question, 0), isFalse);
  });
}
