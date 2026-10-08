class QuestQuestion {
  const QuestQuestion({
    required this.id,
    required this.category,
    required this.prompt,
    required this.choices,
    required this.answerIndex,
    required this.explanation,
  });

  final String id;
  final String category;
  final String prompt;
  final List<String> choices;
  final int answerIndex;
  final String explanation;

  bool isCorrect(int selectedIndex) => selectedIndex == answerIndex;

  factory QuestQuestion.fromJson(Map<String, dynamic> json, String category) =>
      QuestQuestion(
        id: json['id'] as String,
        category: category,
        prompt: json['prompt'] as String,
        choices: List<String>.from(json['choices'] as List),
        answerIndex: json['answer'] as int,
        explanation: json['explanation'] as String,
      );
}

class QuestWorld {
  const QuestWorld(
      this.title, this.emoji, this.subtitle, this.color, this.requiredXp);
  final String title;
  final String emoji;
  final String subtitle;
  final int color;
  final int requiredXp;
}
