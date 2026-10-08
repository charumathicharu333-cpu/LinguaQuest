import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../models/quest_models.dart';
import '../services/app_state.dart';
import '../services/content_service.dart';
import '../widgets/quest_widgets.dart';

class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen(
      {super.key,
      required this.title,
      required this.category,
      required this.gameType});
  final String title;
  final String category;
  final String gameType;

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late Future<List<QuestQuestion>> _questionsFuture;
  late Future<Map<String, dynamic>> _languageFuture;
  List<QuestQuestion> questions = const [];
  List<List<String>> words = const [];
  int questionIndex = 0;
  int score = 0;
  int? selected;
  int secondsLeft = 45;
  Timer? _timer;
  bool complete = false;
  bool timeUp = false;
  final Set<int> matchedCards = {};
  final Set<int> openCards = {};
  final List<String> sentence = [];
  static const _sentenceWords = ['Curiosity', 'leads', 'to', 'discovery'];

  bool get _isTimed => widget.gameType == 'Timed Challenge';
  bool get _isMemory => widget.gameType == 'Memory Cards';

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _questionsFuture =
        ContentService().questions(widget.category, ageGroup: state.ageGroup);
    _languageFuture = ContentService().languagePack(state.language);
    if (_isTimed) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || complete) return timer.cancel();
        if (secondsLeft <= 1) {
          setState(() {
            secondsLeft = 0;
            timeUp = true;
            complete = true;
          });
          timer.cancel();
        } else {
          setState(() => secondsLeft--);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<QuestQuestion>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          questions = snapshot.data ?? const [];
          if (!snapshot.hasData)
            return Scaffold(
                appBar: AppBar(),
                body: const Center(child: CircularProgressIndicator()));
          if (complete) return _base(_result(context));
          if (widget.gameType == 'Word Match') {
            return FutureBuilder<Map<String, dynamic>>(
                future: _languageFuture,
                builder: (context, pack) {
                  words = (((pack.data?['lessons'] as List<dynamic>?)?.first
                                  as Map<String, dynamic>?)?['words']
                              as List<dynamic>?)
                          ?.map((row) => List<String>.from(row as List))
                          .toList() ??
                      const [];
                  return _wordMatch(context);
                });
          }
          if (_isMemory && words.isEmpty) {
            final pack = _languageFuture;
            return FutureBuilder<Map<String, dynamic>>(
                future: pack,
                builder: (context, data) {
                  if (!data.hasData)
                    return Scaffold(
                        appBar: AppBar(),
                        body: const Center(child: CircularProgressIndicator()));
                  final lessons = data.data!['lessons'] as List<dynamic>;
                  words = (lessons.first as Map<String, dynamic>)['words']
                      .cast<List<dynamic>>()
                      .map<List<String>>((row) => List<String>.from(row))
                      .toList();
                  return _memoryGame(context);
                });
          }
          if (widget.gameType == 'Sentence Builder')
            return _sentenceGame(context);
          if (widget.gameType == 'Image Identification')
            return _imageGame(context);
          return _quizGame(context);
        },
      );

  Widget _base(Widget child) => Scaffold(
        appBar: AppBar(
            title: Text(widget.title,
                style: const TextStyle(fontWeight: FontWeight.w900)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Exit'))
            ]),
        body: ScreenColumn(children: [OfflinePill(), child]),
      );

  Widget _quizGame(BuildContext context) {
    if (complete ||
        questions.isEmpty ||
        questionIndex >=
            (widget.gameType == 'Timed Challenge' ? questions.length : 5))
      return _base(_result(context));
    final q = questions[questionIndex];
    return _base(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_isTimed)
        QuestCard(
            color: const Color(0xFFFFE5D7),
            child: Row(children: [
              const Text('⏱️', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              const Text('Take your time, but watch the clock',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('$secondsLeft s',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, color: QuestColors.teal))
            ])),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(widget.category.toUpperCase(),
            style: const TextStyle(
                letterSpacing: 1,
                fontWeight: FontWeight.w900,
                color: QuestColors.teal)),
        Text('${questionIndex + 1} / ${_isTimed ? questions.length : 5}',
            style: const TextStyle(
                color: QuestColors.muted, fontWeight: FontWeight.w800))
      ]),
      const SizedBox(height: 8),
      QuestProgress(
          value: (questionIndex + (selected == null ? 0 : .5)) /
              (_isTimed ? questions.length : 5)),
      const SizedBox(height: 14),
      Text(q.prompt, style: Theme.of(context).textTheme.headlineMedium),
      if (widget.gameType == 'Image Identification')
        const Center(child: Text('🐝', style: TextStyle(fontSize: 58))),
      const SizedBox(height: 10),
      for (var i = 0; i < q.choices.length; i++) _choiceTile(context, q, i),
      if (selected != null && selected != q.answerIndex)
        QuestCard(
            color: const Color(0xFFF0EFEA),
            child: Text(
                '${q.explanation} Give it another try when you are ready.',
                style: const TextStyle(fontWeight: FontWeight.w700))),
      if (selected == q.answerIndex)
        QuestCard(
            color: QuestColors.mint,
            child: Text('That is right! ${q.explanation}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: QuestColors.teal))),
      if (selected == q.answerIndex)
        GameButton(
            label: questionIndex == (_isTimed ? questions.length - 1 : 4)
                ? 'See my results'
                : 'Next question',
            onPressed: () => setState(() {
                  questionIndex++;
                  selected = null;
                  if (!_isTimed && questionIndex >= 5) complete = true;
                }),
            icon: Icons.arrow_forward_rounded),
      if (selected != null && selected != q.answerIndex)
        OutlinedButton.icon(
            onPressed: () => setState(() => selected = null),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again')),
    ]));
  }

  Widget _choiceTile(BuildContext context, QuestQuestion q, int index) {
    final isRight = selected == index && index == q.answerIndex;
    final isWrong = selected == index && index != q.answerIndex;
    return Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Material(
            color: isRight
                ? QuestColors.mint
                : isWrong
                    ? const Color(0xFFFFE2D6)
                    : Colors.white,
            borderRadius: BorderRadius.circular(17),
            child: InkWell(
                onTap: selected == null
                    ? () async {
                        setState(() {
                          selected = index;
                          if (index == q.answerIndex) score++;
                        });
                        await context.read<AppState>().answer(q, index);
                      }
                    : null,
                borderRadius: BorderRadius.circular(17),
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 14),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                            color: isRight
                                ? QuestColors.teal
                                : isWrong
                                    ? QuestColors.coral
                                    : const Color(0xFFE9EEEB))),
                    child: Row(children: [
                      Expanded(
                          child: Text(q.choices[index],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900))),
                      if (isRight)
                        const Icon(Icons.check_circle_rounded,
                            color: QuestColors.teal),
                      if (isWrong)
                        const Icon(Icons.refresh_rounded,
                            color: QuestColors.coral)
                    ])))));
  }

  Widget _wordMatch(BuildContext context) {
    if (words.isEmpty)
      return _base(const Text(
          'This word pack is not available yet. Choose another trail.'));
    final pair = words[questionIndex % words.length];
    final options = [for (final word in words) word[1]];
    return _base(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Find the meaning',
          style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      QuestCard(
          color: const Color(0xFFDDF0E7),
          child: Center(
              child: Text(pair[0],
                  style: Theme.of(context).textTheme.headlineMedium))),
      for (var i = 0; i < options.length; i++)
        _simpleTile(
            options[i], selected == i, selected != null && i == questionIndex,
            () async {
          setState(() {
            selected = i;
            if (i == questionIndex) score++;
          });
          final q = QuestQuestion(
              id: 'match-$questionIndex',
              category: 'Language',
              prompt: pair[0],
              choices: options,
              answerIndex: questionIndex,
              explanation: '${pair[0]} means ${pair[1]}.');
          await context.read<AppState>().answer(q, i);
        }),
      if (selected != null && selected == questionIndex)
        GameButton(
            label: questionIndex == words.length - 1
                ? 'Finish match'
                : 'Next word',
            onPressed: () => setState(() {
                  questionIndex++;
                  selected = null;
                  if (questionIndex >= words.length) complete = true;
                })),
      if (selected != null && selected != questionIndex)
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('A helpful clue: ${pair[0]} means ${pair[1]}.',
              style: const TextStyle(
                  color: QuestColors.muted, fontWeight: FontWeight.w700)),
          TextButton(
              onPressed: () => setState(() => selected = null),
              child: const Text('Try again'))
        ]),
    ]));
  }

  Widget _sentenceGame(BuildContext context) {
    final shuffled = ['discovery', 'Curiosity', 'to', 'leads'];
    final done = sentence.length == _sentenceWords.length;
    final correct = done &&
        List.generate(sentence.length, (i) => sentence[i] == _sentenceWords[i])
            .every((value) => value);
    return _base(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Build a thoughtful sentence',
          style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 7),
      const Text('Tap the words in an order that makes sense.',
          style: TextStyle(color: QuestColors.muted)),
      const SizedBox(height: 20),
      QuestCard(
          color: const Color(0xFFDDEBF5),
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (var i = 0; i < sentence.length; i++)
              Chip(
                  label: Text(sentence[i]),
                  onDeleted: () => setState(() => sentence.removeAt(i)))
          ])),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final word in shuffled)
          if (!sentence.contains(word))
            ActionChip(
                label: Text(word),
                onPressed: () => setState(() => sentence.add(word)))
      ]),
      if (correct)
        QuestCard(
            color: QuestColors.mint,
            child: const Text(
                'Curiosity leads to discovery. A lovely sentence!',
                style: TextStyle(
                    fontWeight: FontWeight.w900, color: QuestColors.teal))),
      if (done && !correct)
        QuestCard(
            color: const Color(0xFFFFE5D7),
            child: const Text(
                'Try a different order. The first word begins with a capital letter.',
                style: TextStyle(fontWeight: FontWeight.w800))),
      if (correct)
        GameButton(
            label: 'Finish sentence',
            onPressed: () async {
              await _award(context, 'sentence-builder',
                  'Curiosity leads to discovery.', 0);
              setState(() => complete = true);
            }),
      if (done && !correct)
        TextButton(
            onPressed: () => setState(sentence.clear),
            child: const Text('Clear and try again')),
    ]));
  }

  Widget _memoryGame(BuildContext context) {
    final cardLabels = [
      for (var i = 0; i < words.length; i++) words[i][0],
      for (var i = words.length - 1; i >= 0; i--) words[i][1]
    ];
    final allDone = matchedCards.length == words.length;
    if (allDone)
      return _base(Column(children: [
        Text('Pairs found!', style: Theme.of(context).textTheme.headlineMedium),
        const Text('You held all the words in your memory. Nice work.'),
        GameButton(
            label: 'See my results',
            onPressed: () => setState(() => complete = true))
      ]));
    return _base(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Find the word pairs',
          style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Text('Tap one card, then its matching translation.',
          style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 14),
      GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cardLabels.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 9,
              crossAxisSpacing: 9,
              childAspectRatio: 1.8),
          itemBuilder: (context, index) {
            final pairIndex = index < words.length
                ? index
                : (words.length - 1) - (index - words.length);
            final isOpen = openCards.contains(index) ||
                matchedCards.contains(pairIndex + 100);
            return InkWell(
                onTap: isOpen
                    ? null
                    : () async {
                        if (openCards.length >= 2) return;
                        if (openCards.isEmpty)
                          return setState(() => openCards.add(index));
                        final prior = openCards.first;
                        setState(() => openCards.add(index));
                        if ((prior < words.length) != (index < words.length) &&
                            pairIndex ==
                                (prior < words.length
                                    ? prior
                                    : words.length -
                                        1 -
                                        (prior - words.length))) {
                          setState(() {
                            matchedCards.add(pairIndex + 100);
                            openCards.clear();
                            score++;
                          });
                          final q = QuestQuestion(
                              id: 'memory-$pairIndex',
                              category: 'Language',
                              prompt: 'Match',
                              choices: const ['A', 'B'],
                              answerIndex: 0,
                              explanation: 'You found the pair.');
                          await context.read<AppState>().answer(q, 0);
                        } else {
                          Future.delayed(const Duration(milliseconds: 850), () {
                            if (mounted) setState(openCards.clear);
                          });
                        }
                      },
                child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: isOpen ? QuestColors.mint : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: isOpen
                                ? QuestColors.teal
                                : const Color(0xFFE5EBE7))),
                    child: Text(isOpen ? cardLabels[index] : '✦',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: isOpen ? 15 : 25,
                            color: QuestColors.ink))));
          }),
    ]));
  }

  Widget _imageGame(BuildContext context) {
    const options = ['Bee', 'Butterfly', 'Ladybug', 'Dragonfly'];
    final q = QuestQuestion(
        id: 'image-bee',
        category: 'Nature',
        prompt: 'Which little visitor helps flowers by carrying pollen?',
        choices: options,
        answerIndex: 0,
        explanation: 'Bees move pollen between flowers as they gather nectar.');
    return _base(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Picture clue', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 12),
      const QuestCard(
          color: Color(0xFFDDF0E7),
          child: Center(
              child: Text('🌼  🐝  🌼', style: TextStyle(fontSize: 58)))),
      const SizedBox(height: 8),
      Text(q.prompt, style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 14),
      for (var i = 0; i < options.length; i++) _choiceTile(context, q, i),
      if (selected == 0)
        GameButton(
            label: 'See my result',
            onPressed: () => setState(() => complete = true)),
      if (selected != null && selected != 0)
        TextButton(
            onPressed: () => setState(() => selected = null),
            child: const Text('Try another answer'))
    ]));
  }

  Widget _simpleTile(
          String label, bool wrong, bool correct, VoidCallback onTap) =>
      Padding(
          padding: const EdgeInsets.only(top: 9),
          child: Material(
              color: correct
                  ? QuestColors.mint
                  : wrong
                      ? const Color(0xFFFFE5D7)
                      : Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                  onTap: selected == null ? onTap : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      child: Text(label,
                          style:
                              const TextStyle(fontWeight: FontWeight.w900))))));

  Widget _result(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(
            child: Text(timeUp ? '⏳' : '🎉',
                style: const TextStyle(fontSize: 66))),
        Text(timeUp ? 'Time for a breather' : 'Round complete!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
            timeUp
                ? 'You made it through $score questions. Come back when you are ready.'
                : 'You earned $score bright answer${score == 1 ? '' : 's'}. Every try helps your ideas grow.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 18),
        QuestCard(
            color: const Color(0xFFFFE6BE),
            child: Center(
                child: Text('+$xpReward XP',
                    style: const TextStyle(
                        fontSize: 23, fontWeight: FontWeight.w900)))),
        GameButton(
            label: 'Back to games', onPressed: () => Navigator.pop(context))
      ]);

  int get xpReward => score * 10;

  Future<void> _award(
      BuildContext context, String id, String prompt, int answer) async {
    final q = QuestQuestion(
        id: id,
        category: 'Language',
        prompt: prompt,
        choices: const ['Correct'],
        answerIndex: answer,
        explanation: 'Well assembled.');
    await context.read<AppState>().answer(q, answer);
  }
}
