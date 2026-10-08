import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../models/quest_models.dart';
import '../services/app_state.dart';
import '../services/audio_service.dart';
import '../services/content_service.dart';
import '../widgets/quest_widgets.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, this.lessonIndex = 0, this.title});
  final int lessonIndex;
  final String? title;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int phase = 0;
  int wordIndex = 0;
  int? selected;
  bool matched = false;
  bool _selectedWasWrong = false;
  final _audio = AudioService();

  static const _phaseNames = ['Learn', 'Practice', 'Game', 'Quiz', 'Reward'];

  @override
  void dispose() {
    unawaited(_audio.dispose());
    super.dispose();
  }

  void _advance() {
    setState(() {
      selected = null;
      matched = false;
      _selectedWasWrong = false;
      if (phase == 0 && wordIndex < 2) {
        wordIndex++;
      } else {
        phase++;
        wordIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return FutureBuilder<Map<String, dynamic>>(
      future: ContentService().languagePack(state.language),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()));
        final lessons = snapshot.data!['lessons'] as List<dynamic>;
        final lesson =
            lessons[widget.lessonIndex.clamp(0, lessons.length - 1).toInt()]
                as Map<String, dynamic>;
        final words = (lesson['words'] as List<dynamic>)
            .map((row) => List<String>.from(row as List))
            .toList();
        final word = words[wordIndex.clamp(0, words.length - 1).toInt()];
        final title = widget.title ?? lesson['title'] as String;
        return Scaffold(
          appBar: AppBar(
              title: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Exit'))
              ]),
          body: SafeArea(
            top: false,
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Column(children: [
                    QuestProgress(
                        value: (phase + (phase == 0 ? wordIndex / 3 : 0)) / 5),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              _phaseNames[phase.clamp(0, 4).toInt()]
                                  .toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  color: QuestColors.teal)),
                          Text('Age trail · ${state.ageGroup}',
                              style: const TextStyle(
                                  color: QuestColors.muted, fontSize: 12))
                        ])
                  ])),
              Expanded(
                  child: ListView(
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
                      children: [
                    if (phase == 0) ...[
                      Text('A few useful words',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                          'Take your time. Tap the sound button if one is available.',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 20),
                      QuestCard(
                          color: const Color(0xFFDDF0E7),
                          padding: const EdgeInsets.all(25),
                          child: Column(children: [
                            Text(word[0],
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.headlineLarge),
                            const SizedBox(height: 10),
                            Text(word[1],
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: QuestColors.teal)),
                            const SizedBox(height: 16),
                            IconButton.filledTonal(
                                onPressed: () async {
                                  final soundsEnabled = await state.database
                                          .setting('sounds', 'true') ==
                                      'true';
                                  if (!context.mounted) return;
                                  if (!soundsEnabled) {
                                    showQuestMessage(context,
                                        'Word sounds are turned off in Settings.');
                                    return;
                                  }
                                  final played = await _audio.playWord(
                                      state.language,
                                      'word-${widget.lessonIndex}-$wordIndex');
                                  if (!context.mounted) return;
                                  showQuestMessage(
                                      context,
                                      played
                                          ? 'Playing a local word clip.'
                                          : 'No audio clip for this word yet. You can keep learning by reading it.');
                                },
                                icon: const Icon(Icons.volume_up_rounded),
                                tooltip: 'Play word')
                          ])),
                      const SizedBox(height: 18),
                      Text('Word ${wordIndex + 1} of 3',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: QuestColors.muted,
                              fontWeight: FontWeight.w800)),
                    ] else if (phase == 1) ...[
                      Text('Practice the meaning',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 9),
                      Text('Which word means “${word[1]}”?',
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 18),
                      for (var i = 0; i < words.length; i++)
                        _AnswerTile(
                            label: words[i][0],
                            selected: selected == i,
                            correct: i == wordIndex,
                            revealed: selected != null,
                            onTap: selected == null
                                ? () async {
                                    setState(() {
                                      selected = i;
                                      _selectedWasWrong = i != wordIndex;
                                    });
                                    await state.answer(
                                        _question(words, wordIndex,
                                            'practice-$wordIndex'),
                                        i);
                                  }
                                : null),
                      if (selected != null)
                        Text(
                            selected == wordIndex
                                ? 'That is it. Nice noticing!'
                                : 'Not quite. ${word[0]} means ${word[1]}. Try the next one when ready.',
                            style: TextStyle(
                                color: selected == wordIndex
                                    ? QuestColors.teal
                                    : QuestColors.muted,
                                fontWeight: FontWeight.w900)),
                    ] else if (phase == 2) ...[
                      Text('Quick match game',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text('Tap the matching pair to finish this round.',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 20),
                      for (var i = 0; i < 2; i++)
                        Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: QuestCard(
                                color: i == 0
                                    ? const Color(0xFFFFE7D8)
                                    : const Color(0xFFDDEBF5),
                                onTap: () {
                                  if (i == 1) setState(() => matched = true);
                                },
                                child: Row(children: [
                                  Text(
                                      i == 0
                                          ? word[0]
                                          : (matched
                                              ? word[1]
                                              : 'Tap to reveal its meaning'),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18)),
                                  const Spacer(),
                                  Icon(
                                      matched
                                          ? Icons.check_circle_rounded
                                          : Icons.touch_app_rounded,
                                      color: QuestColors.teal)
                                ]))),
                      if (matched)
                        const Text('Pair found! Words stick when you use them.',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: QuestColors.teal)),
                    ] else if (phase == 3) ...[
                      Text('One last check-in',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 9),
                      Text('How do you say “${word[0]}” in this trail?',
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 18),
                      for (var i = 0; i < words.length; i++)
                        _AnswerTile(
                            label: words[i][1],
                            selected: selected == i,
                            correct: i == wordIndex,
                            revealed: selected != null,
                            onTap: selected == null
                                ? () async {
                                    setState(() {
                                      selected = i;
                                      _selectedWasWrong = i != wordIndex;
                                    });
                                    await state.answer(
                                        _question(words, wordIndex,
                                            'quiz-$wordIndex'),
                                        i);
                                  }
                                : null),
                      if (selected != null)
                        Text(
                            selected == wordIndex
                                ? 'You found it. Every new word is a little passport.'
                                : 'The answer is ${word[1]}. It is okay to try again in another round.',
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: QuestColors.teal)),
                    ] else ...[
                      const Center(
                          child: Text('✨', style: TextStyle(fontSize: 68))),
                      Text('Quest complete!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge),
                      const SizedBox(height: 10),
                      Text(
                          'You explored ${lesson['topic']}. That is a lovely use of a few minutes.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      const QuestCard(
                          color: Color(0xFFFFE6BE),
                          child: Center(
                              child: Text(
                                  'Lesson reward +25 XP   ·   Daily quest +100 XP',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: QuestColors.ink)))),
                    ],
                  ])),
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                  child: GameButton(
                      label: phase == 4
                          ? 'Back to the map'
                          : _selectedWasWrong
                              ? 'Try again'
                              : phase == 3
                                  ? 'Finish lesson'
                                  : 'Continue',
                      onPressed: () async {
                        if (phase == 4) {
                          Navigator.pop(context);
                        } else if (_selectedWasWrong) {
                          setState(() {
                            selected = null;
                            _selectedWasWrong = false;
                          });
                        } else if (phase == 0 || phase == 1 || phase == 2) {
                          if (phase == 1 && selected != wordIndex) {
                            showQuestMessage(context,
                                'Choose the matching answer to continue.');
                          } else if (phase == 2 && !matched) {
                            showQuestMessage(context,
                                'Tap the second card to make a match.');
                          } else {
                            _advance();
                          }
                        } else if (phase == 3 && selected == wordIndex) {
                          await state.completeLesson(
                              '${state.language}-${widget.lessonIndex}');
                          if (mounted) {
                            setState(() => phase = 4);
                            if (await state.database
                                        .setting('break_reminders', 'false') ==
                                    'true' &&
                                context.mounted) {
                              showQuestMessage(context,
                                  'You finished a learning session. A short breather is here if you would like one.');
                            }
                          }
                        } else {
                          showQuestMessage(context,
                              'Choose the matching answer to continue. You can take your time.');
                        }
                      },
                      icon: phase == 4
                          ? Icons.map_rounded
                          : Icons.arrow_forward_rounded)),
            ]),
          ),
        );
      },
    );
  }

  QuestQuestion _question(List<List<String>> words, int correct, String id) =>
      QuestQuestion(
        id: id,
        category: 'Language',
        prompt: 'Choose the matching word',
        choices: [for (final pair in words) pair[0]],
        answerIndex: correct,
        explanation: 'That is the correct match.',
      );
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile(
      {required this.label,
      required this.selected,
      required this.correct,
      required this.revealed,
      required this.onTap});
  final String label;
  final bool selected;
  final bool correct;
  final bool revealed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final good = revealed && correct;
    final wrong = selected && !correct;
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
            color: good
                ? QuestColors.mint
                : wrong
                    ? const Color(0xFFFFE2D6)
                    : Colors.white,
            borderRadius: BorderRadius.circular(17),
            child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(17),
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                            color: good
                                ? QuestColors.teal
                                : wrong
                                    ? QuestColors.coral
                                    : const Color(0xFFE9EEEB))),
                    child: Text(label,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900))))));
  }
}
