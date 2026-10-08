import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../models/quest_models.dart';
import '../services/app_state.dart';
import '../services/content_service.dart';
import '../services/progress_service.dart';
import '../widgets/quest_widgets.dart';
import 'lesson_screen.dart';
import 'profile_screens.dart';
import 'game_screens.dart';

const questWorlds = [
  QuestWorld(
      'Welcome Village', '🏡', 'Your first tiny discoveries', 0xFFD8F0E7, 0),
  QuestWorld(
      'Vocabulary Village', '📚', 'Words that open doors', 0xFFFFE3CE, 100),
  QuestWorld('Grammar Garden', '🌱', 'Grow your sentences', 0xFFE7F0C8, 200),
  QuestWorld('Conversation City', '🏙️', 'Find your voice', 0xFFDCE9F5, 300),
  QuestWorld('Science Lab', '🧪', 'Try a curious experiment', 0xFFDDEFEA, 400),
  QuestWorld('Space Zone', '🚀', 'Look beyond the horizon', 0xFFE8E1F8, 500),
  QuestWorld('Nature Park', '🌳', 'Notice the living world', 0xFFDDF0DD, 600),
  QuestWorld(
      'Geography World', '🌍', 'Find your place on Earth', 0xFFDDEAF2, 700),
  QuestWorld('History Land', '🏛️', 'Stories across time', 0xFFF5E7D4, 800),
  QuestWorld('Technology Hub', '💻', 'How useful things work', 0xFFDCEBF5, 900),
  QuestWorld(
      'Knowledge Castle', '🏰', 'Bring your ideas together', 0xFFF3E2EC, 1000),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ScreenColumn(children: [
      Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('LINGUAQUEST',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(letterSpacing: 1.1)),
          Text('Your adventure map',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium)
        ])),
        const SizedBox(width: 9),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const OfflinePill(),
          const SizedBox(height: 5),
          Text('✨ ${state.xp} XP  ·  Level ${state.level}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, color: QuestColors.ink))
        ]),
      ]),
      QuestCard(
        color: const Color(0xFF173C50),
        child: Stack(children: [
          Positioned(
              right: 0,
              top: 0,
              child: Text('🧭',
                  style: TextStyle(
                      fontSize: 48,
                      color: Colors.white.withValues(alpha: .95)))),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('A new world awaits',
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text('Little steps.\nBig discoveries.',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.white)),
            const SizedBox(height: 14),
            SizedBox(
                width: 178,
                child: ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LessonScreen())),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: QuestColors.lime,
                        foregroundColor: QuestColors.ink,
                        minimumSize: const Size(0, 46)),
                    child: const Text('Continue learning'))),
          ]),
        ]),
      ),
      QuestCard(
        color: const Color(0xFFFFE2D6),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MissionScreen())),
        child: Row(children: [
          const Text('🌟', style: TextStyle(fontSize: 33)),
          const SizedBox(width: 13),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text("TODAY'S QUEST",
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w900,
                        color: QuestColors.teal)),
                const SizedBox(height: 3),
                Text(
                    state.dailyQuestComplete
                        ? 'Quest complete. Lovely work!'
                        : 'Complete 1 short lesson',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                QuestProgress(
                    value: state.dailyQuestComplete ? 1 : 0,
                    color: QuestColors.coral,
                    height: 7)
              ])),
          const SizedBox(width: 10),
          Text(state.dailyQuestComplete ? '✓' : '+100\nXP',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, color: QuestColors.teal)),
        ]),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Explore the map',
            style: Theme.of(context).textTheme.headlineMedium),
        Text('Level ${state.level}',
            style: const TextStyle(
                color: QuestColors.muted, fontWeight: FontWeight.w800))
      ]),
      for (var i = 0; i < questWorlds.length; i++)
        _WorldTile(
            world: questWorlds[i],
            index: i,
            unlocked: ProgressService.isWorldUnlocked(i, state.xp),
            onTap: () {
              if (!ProgressService.isWorldUnlocked(i, state.xp)) {
                showQuestMessage(context,
                    'Keep exploring to unlock ${questWorlds[i].title}.');
                return;
              }
              if (i < 2) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LessonScreen()));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => GamePlayScreen(
                            title: questWorlds[i].title,
                            category: i == 7
                                ? 'Geography'
                                : i == 4
                                    ? 'Science'
                                    : 'General Knowledge',
                            gameType: 'Multiple Choice Quiz')));
              }
            }),
    ]);
  }
}

class _WorldTile extends StatelessWidget {
  const _WorldTile(
      {required this.world,
      required this.index,
      required this.unlocked,
      required this.onTap});
  final QuestWorld world;
  final int index;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(children: [
        SizedBox(
            width: 44,
            child: Column(children: [
              Container(
                  width: 3,
                  height: 10,
                  color: index == 0
                      ? Colors.transparent
                      : const Color(0xFFD4E0DA)),
              Container(
                  width: 35,
                  height: 35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color:
                          unlocked ? QuestColors.teal : const Color(0xFFE8ECE8),
                      shape: BoxShape.circle),
                  child: Icon(
                      unlocked ? Icons.check_rounded : Icons.lock_rounded,
                      size: 17,
                      color: unlocked ? Colors.white : QuestColors.muted)),
              Container(width: 3, height: 10, color: const Color(0xFFD4E0DA))
            ])),
        Expanded(
            child: QuestCard(
                color: Color(world.color),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                onTap: onTap,
                child: Row(children: [
                  Text(world.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(world.title,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w900)),
                        Text(
                            unlocked
                                ? world.subtitle
                                : 'Unlock at ${world.requiredXp} XP',
                            style: const TextStyle(
                                fontSize: 12, color: QuestColors.muted))
                      ])),
                  Icon(
                      unlocked
                          ? Icons.arrow_forward_ios_rounded
                          : Icons.lock_outline_rounded,
                      size: 16,
                      color: QuestColors.ink)
                ]))),
      ]);
}

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return FutureBuilder<Map<String, dynamic>>(
      future: ContentService().languagePack(state.language),
      builder: (context, snapshot) {
        final pack = snapshot.data;
        final lessons = (pack?['lessons'] as List<dynamic>?) ?? const [];
        return ScreenColumn(children: [
          Text('Choose a trail',
              style: Theme.of(context).textTheme.headlineLarge),
          Text(
              'Short, self-paced lessons in ${state.languageName}. Your progress stays on this device.',
              style: Theme.of(context).textTheme.bodyMedium),
          const OfflinePill(),
          for (var i = 0; i < lessons.length; i++)
            _LessonCard(
                language: state.language,
                index: i,
                lesson: lessons[i] as Map<String, dynamic>),
          QuestCard(
              color: const Color(0xFFDDEBF5),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const GameZoneScreen())),
              child: const Row(children: [
                Text('🧩', style: TextStyle(fontSize: 30)),
                SizedBox(width: 12),
                Expanded(
                    child: Text('Want a quick puzzle instead?',
                        style: TextStyle(fontWeight: FontWeight.w900))),
                Icon(Icons.arrow_forward_rounded)
              ])),
        ]);
      },
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard(
      {required this.language, required this.index, required this.lesson});
  final String language;
  final int index;
  final Map<String, dynamic> lesson;

  @override
  Widget build(BuildContext context) => QuestCard(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => LessonScreen(
                    lessonIndex: index, title: lesson['title'] as String))),
        child: Row(children: [
          Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: const Color(0xFFFFE7CD),
                  borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.auto_stories_rounded,
                  color: QuestColors.ink)),
          const SizedBox(width: 13),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(lesson['title'] as String,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 16)),
                Text('${lesson['topic']} · 3 min',
                    style: const TextStyle(color: QuestColors.muted))
              ])),
          const Icon(Icons.play_circle_fill_rounded,
              color: QuestColors.teal, size: 31)
        ]),
      );
}

class GameZoneScreen extends StatelessWidget {
  const GameZoneScreen({super.key});

  static const games = [
    (
      'Multiple Choice Quiz',
      '🧠',
      'Pick the answer that fits',
      'General Knowledge'
    ),
    ('Word Match', '🔗', 'Pair words with meanings', 'English'),
    ('Sentence Builder', '🧱', 'Put a phrase in order', 'English'),
    ('Memory Cards', '🃏', 'Find matching pairs', 'English'),
    ('Timed Challenge', '⏱️', 'A quick round against the clock', 'Science'),
    (
      'Image Identification',
      '🖼️',
      'Name the picture clue',
      'General Knowledge'
    ),
    ('Logic Puzzle', '🧩', 'Spot the pattern', 'Logic'),
  ];

  @override
  Widget build(BuildContext context) => ScreenColumn(children: [
        Text('Game Zone', style: Theme.of(context).textTheme.headlineLarge),
        Text('Play a quick round. Every answer is a chance to learn.',
            style: Theme.of(context).textTheme.bodyMedium),
        const OfflinePill(),
        for (final game in games)
          QuestCard(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => GamePlayScreen(
                        title: game.$1, category: game.$4, gameType: game.$1))),
            child: Row(children: [
              Text(game.$2, style: const TextStyle(fontSize: 31)),
              const SizedBox(width: 13),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(game.$1,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900)),
                    Text(game.$3,
                        style: const TextStyle(color: QuestColors.muted))
                  ])),
              const Icon(Icons.arrow_forward_rounded, color: QuestColors.teal)
            ]),
          ),
      ]);
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ScreenColumn(children: [
      Text('Your discoveries',
          style: Theme.of(context).textTheme.headlineLarge),
      Text('A gentle look at how far you have travelled.',
          style: Theme.of(context).textTheme.bodyMedium),
      QuestCard(
          color: const Color(0xFF173C50),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('LEVEL ${state.level}',
                style: const TextStyle(
                    color: QuestColors.lime,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1)),
            const SizedBox(height: 5),
            Text('${state.xp} XP collected',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.white)),
            const SizedBox(height: 13),
            QuestProgress(value: state.levelProgress, color: QuestColors.lime),
            const SizedBox(height: 8),
            Text(
                '${(state.levelProgress * 250).round()} / 250 XP to your next level',
                style: const TextStyle(color: Colors.white70))
          ])),
      Row(children: [
        Expanded(
            child: _StatCard(
                value: '${state.lessonsCompleted}',
                label: 'Lessons',
                emoji: '📖',
                color: QuestColors.mint)),
        const SizedBox(width: 12),
        Expanded(
            child: _StatCard(
                value: '${state.correctAnswers}',
                label: 'Bright answers',
                emoji: '💡',
                color: const Color(0xFFFFE5D7)))
      ]),
      Row(children: [
        Expanded(
            child: _StatCard(
                value: '${state.badges}',
                label: 'Badges',
                emoji: '🏅',
                color: const Color(0xFFEAE4F7))),
        const SizedBox(width: 12),
        Expanded(
            child: _StatCard(
                value: '${state.learningMinutes} min',
                label: 'Learning time*',
                emoji: '⏳',
                color: const Color(0xFFE3EEF5)))
      ]),
      Row(children: [
        Expanded(
            child: _StatCard(
                value: '${state.streak} days',
                label: 'Learning rhythm',
                emoji: '🌿',
                color: const Color(0xFFE5F0D5))),
        const SizedBox(width: 12),
        Expanded(
            child: _StatCard(
                value: '${(state.xp ~/ 100) + 1}',
                label: 'Map stops open',
                emoji: '🗺️',
                color: const Color(0xFFFFE8D4)))
      ]),
      Text('Your badges', style: Theme.of(context).textTheme.headlineMedium),
      FutureBuilder<List<Map<String, Object?>>>(
          future: context.read<AppState>().database.achievements(),
          builder: (context, snapshot) => Column(children: [
                for (final badge in snapshot.data ?? const [])
                  QuestCard(
                      color: badge['unlocked'] == 1
                          ? const Color(0xFFFFEAB6)
                          : const Color(0xFFEEF0EB),
                      child: Row(children: [
                        Text(badge['emoji'] as String,
                            style: const TextStyle(fontSize: 27)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(badge['title'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900)),
                              Text(badge['description'] as String,
                                  style:
                                      const TextStyle(color: QuestColors.muted))
                            ])),
                        Text(badge['unlocked'] == 1 ? 'EARNED' : 'NEXT',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: QuestColors.teal))
                      ]))
              ])),
      const Text(
          '*A gentle estimate based on activities completed on this device.',
          style: TextStyle(color: QuestColors.muted, fontSize: 12)),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.value,
      required this.label,
      required this.emoji,
      required this.color});
  final String value;
  final String label;
  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) => QuestCard(
      color: color,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label,
            style: const TextStyle(color: QuestColors.muted, fontSize: 12))
      ]));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ScreenColumn(children: [
      Text('Explorer profile',
          style: Theme.of(context).textTheme.headlineLarge),
      QuestCard(
          color: const Color(0xFFDDF0E7),
          child: Row(children: [
            const Text('🧑‍🚀', style: TextStyle(fontSize: 44)),
            const SizedBox(width: 15),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Curious Explorer',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text('${state.ageGroup} age trail · ${state.languageName}',
                      style: const TextStyle(color: QuestColors.muted))
                ]))
          ])),
      _ProfileLink(
          icon: Icons.family_restroom_rounded,
          title: 'Parent dashboard',
          subtitle: 'A calm snapshot of learning',
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ParentDashboardScreen()))),
      _ProfileLink(
          icon: Icons.workspace_premium_rounded,
          title: 'LinguaQuest Plus',
          subtitle: 'See what could grow next',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PremiumScreen()))),
      _ProfileLink(
          icon: Icons.settings_rounded,
          title: 'Settings',
          subtitle: 'Language, age range, and wellbeing',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()))),
      const QuestCard(
          color: Color(0xFFF0EFEA),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Designed with care',
                style: TextStyle(fontWeight: FontWeight.w900)),
            SizedBox(height: 5),
            Text(
                'No public chat. No precise location. No account required. Core adventures work offline.',
                style: TextStyle(color: QuestColors.muted, height: 1.45))
          ])),
    ]);
  }
}

class _ProfileLink extends StatelessWidget {
  const _ProfileLink(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => QuestCard(
      onTap: onTap,
      child: Row(children: [
        RoundIcon(icon: icon),
        const SizedBox(width: 13),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          Text(subtitle, style: const TextStyle(color: QuestColors.muted))
        ])),
        const Icon(Icons.chevron_right_rounded)
      ]));
}

class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
        appBar: AppBar(
            title: const Text("Today's quest",
                style: TextStyle(fontWeight: FontWeight.w900))),
        body: ScreenColumn(children: [
          const Center(child: Text('🌟', style: TextStyle(fontSize: 64))),
          Text(
              state.dailyQuestComplete
                  ? 'Quest complete!'
                  : 'One small step is a great adventure.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium),
          Text(
              state.dailyQuestComplete
                  ? 'Lovely work. Take a break and come back whenever you are ready for your next adventure.'
                  : 'Complete one short lesson to collect your daily reward.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge),
          QuestCard(
              color: const Color(0xFFFFE4D8),
              child: Row(children: [
                const Text('📖', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Complete 1 short lesson',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                      QuestProgress(
                          value: state.dailyQuestComplete ? 1 : 0,
                          color: QuestColors.coral)
                    ])),
                const SizedBox(width: 9),
                Text(state.dailyQuestComplete ? 'DONE' : '+100 XP',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, color: QuestColors.teal))
              ])),
          GameButton(
              label: state.dailyQuestComplete
                  ? 'Return to your map'
                  : 'Start a short lesson',
              onPressed: () {
                if (state.dailyQuestComplete)
                  Navigator.pop(context);
                else
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LessonScreen()));
              }),
          const Text('No streak loss or penalty if you take a day off.',
              textAlign: TextAlign.center,
              style: TextStyle(color: QuestColors.muted)),
        ]));
  }
}
