import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../services/app_state.dart';
import '../widgets/quest_widgets.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
        appBar: AppBar(
            title: const Text('Parent dashboard',
                style: TextStyle(fontWeight: FontWeight.w900))),
        body: ScreenColumn(children: [
          QuestCard(
              color: const Color(0xFF173C50),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('A thoughtful learning habit',
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('${state.learningMinutes} minutes',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text(
                        'Estimated from lessons and practice on this device.',
                        style: TextStyle(color: Colors.white70))
                  ])),
          Row(children: [
            Expanded(
                child: _ParentStat(
                    value: '${state.lessonsCompleted}',
                    label: 'Lessons completed',
                    emoji: '📚')),
            const SizedBox(width: 12),
            Expanded(
                child: _ParentStat(
                    value: '${state.correctAnswers}',
                    label: 'Knowledge answers',
                    emoji: '💡'))
          ]),
          Row(children: [
            Expanded(
                child: _ParentStat(
                    value: '${state.streak} days',
                    label: 'Learning rhythm',
                    emoji: '🌿')),
            const SizedBox(width: 12),
            Expanded(
                child: _ParentStat(
                    value: '${state.badges}',
                    label: 'Achievements',
                    emoji: '🏅'))
          ]),
          Row(children: [
            Expanded(
                child: _ParentStat(
                    value: state.languageName,
                    label: 'Language trail',
                    emoji: '🗺️')),
            const SizedBox(width: 12),
            Expanded(
                child: _ParentStat(
                    value: '${state.badges}',
                    label: 'Achievements',
                    emoji: '🏅'))
          ]),
          const Text('Topics in this offline pack',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const QuestCard(
              color: Color(0xFFDDF0E7),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                Chip(label: Text('🧪 Science')),
                Chip(label: Text('🌍 Geography')),
                Chip(label: Text('✨ General knowledge')),
                Chip(label: Text('🧩 Logic')),
                Chip(label: Text('🗣️ Languages'))
              ])),
          const QuestCard(
              color: Color(0xFFF1EFE9),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Privacy, by design',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    SizedBox(height: 7),
                    Text(
                        'No child account or real name is required. Progress stays in local app storage. There is no public chat, precise location, or targeted advertising.',
                        style: TextStyle(color: QuestColors.muted, height: 1.5))
                  ])),
          const OfflinePill(),
        ]));
  }
}

class _ParentStat extends StatelessWidget {
  const _ParentStat(
      {required this.value, required this.label, required this.emoji});
  final String value;
  final String label;
  final String emoji;

  @override
  Widget build(BuildContext context) => QuestCard(
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label,
            style: const TextStyle(color: QuestColors.muted, fontSize: 12))
      ]));
}

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: const Text('LinguaQuest Plus',
              style: TextStyle(fontWeight: FontWeight.w900))),
      body: ScreenColumn(children: [
        const Center(child: Text('✨', style: TextStyle(fontSize: 64))),
        Text('More worlds, when you are ready.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge),
        const Text(
            'This preview is completely free. Core lessons, games, and child-safety features are not paywalled.',
            textAlign: TextAlign.center,
            style: TextStyle(color: QuestColors.muted, height: 1.5)),
        const QuestCard(
            color: Color(0xFFFFE7C5),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('A future Plus membership could include',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              SizedBox(height: 8),
              Text(
                  '• More language packs\n• Advanced adventure worlds\n• Extra games and speaking practice\n• No advertising',
                  style: TextStyle(height: 1.65, color: QuestColors.ink))
            ])),
        for (final plan in ['Monthly', 'Yearly', 'Lifetime'])
          QuestCard(
              color: Colors.white,
              child: Row(children: [
                const Icon(Icons.stars_rounded, color: QuestColors.teal),
                const SizedBox(width: 11),
                Expanded(
                    child: Text('LinguaQuest Plus · $plan',
                        style: const TextStyle(fontWeight: FontWeight.w900))),
                OutlinedButton(
                    onPressed: () => showQuestMessage(
                        context, 'Purchases are not enabled in this free MVP.'),
                    child: const Text('Coming later'))
              ])),
        const Text(
            'Billing is isolated behind a service interface and is not connected in this MVP.',
            textAlign: TextAlign.center,
            style: TextStyle(color: QuestColors.muted, fontSize: 12)),
      ]));
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool sounds = true;
  bool breakReminders = false;
  bool loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loaded) return;
    loaded = true;
    _load();
  }

  Future<void> _load() async {
    final db = context.read<AppState>().database;
    final sound = await db.setting('sounds', 'true');
    final breaks = await db.setting('break_reminders', 'false');
    if (mounted)
      setState(() {
        sounds = sound == 'true';
        breakReminders = breaks == 'true';
      });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
        appBar: AppBar(
            title: const Text('Settings',
                style: TextStyle(fontWeight: FontWeight.w900))),
        body: ScreenColumn(children: [
          Text('Your trail, your pace.',
              style: Theme.of(context).textTheme.headlineMedium),
          QuestCard(
              color: const Color(0xFFDDF0E7),
              child: Row(children: [
                const Icon(Icons.wifi_off_rounded, color: QuestColors.teal),
                const SizedBox(width: 12),
                const Expanded(
                    child: Text(
                        'Bundled lessons and games are available offline.',
                        style: TextStyle(fontWeight: FontWeight.w800))),
                TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PrivacyScreen())),
                    child: const Text('Details'))
              ])),
          const Text('AGE RANGE',
              style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w900,
                  color: QuestColors.muted)),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final age in ['6-10', '11-14', '15-18', '18+'])
              ChoiceChip(
                  label: Text(age),
                  selected: state.ageGroup == age,
                  onSelected: (_) async {
                    await state.finishOnboarding(age, state.language);
                  })
          ]),
          const Text('LEARNING LANGUAGE',
              style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w900,
                  color: QuestColors.muted)),
          for (final item in [
            ('en', '🇬🇧', 'English'),
            ('hi', '🇮🇳', 'Hindi'),
            ('ja', '🇯🇵', 'Japanese')
          ])
            QuestCard(
                color:
                    state.language == item.$1 ? QuestColors.mint : Colors.white,
                onTap: () => state.setLanguage(item.$1),
                child: Row(children: [
                  Text(item.$2, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(item.$3,
                          style: const TextStyle(fontWeight: FontWeight.w900))),
                  if (state.language == item.$1)
                    const Icon(Icons.check_circle, color: QuestColors.teal)
                ])),
          SwitchListTile(
              value: sounds,
              title: const Text('Sound effects',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle:
                  const Text('Word audio may not be included for every pack.'),
              onChanged: (value) async {
                setState(() => sounds = value);
                await state.database.saveSetting('sounds', '$value');
              }),
          SwitchListTile(
              value: breakReminders,
              title: const Text('Optional break reminders',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle:
                  const Text('Gentle pause reminders. Never a streak penalty.'),
              onChanged: (value) async {
                setState(() => breakReminders = value);
                await state.database.saveSetting('break_reminders', '$value');
              }),
          const QuestCard(
              color: Color(0xFFF1EFE9),
              child: Text(
                  'Take breaks whenever you like. There are no lost lives, countdown pressure outside optional games, or penalty for taking a day off.',
                  style: TextStyle(color: QuestColors.muted, height: 1.5))),
          ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy and local data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PrivacyScreen()))),
          const Center(
              child: Text('LinguaQuest · MVP 1.0',
                  style: TextStyle(color: QuestColors.muted))),
        ]));
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: const Text('Privacy, simply',
              style: TextStyle(fontWeight: FontWeight.w900))),
      body: ScreenColumn(children: [
        Text('Learning stays on this device.',
            style: Theme.of(context).textTheme.headlineLarge),
        const QuestCard(
            color: Color(0xFFDDF0E7),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Collected locally for the app to work',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              SizedBox(height: 9),
              Text(
                  'Age range, selected learning language, lesson activity, answers, XP, badges, and settings are stored in the app’s local SQLite database.',
                  style: TextStyle(height: 1.5, color: QuestColors.ink))
            ])),
        const QuestCard(
            color: Colors.white,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Not requested by this MVP',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              SizedBox(height: 9),
              Text(
                  'Real name, precise location, contacts, public profile, public messaging, targeted advertising, or a cloud account.',
                  style: TextStyle(height: 1.5, color: QuestColors.muted))
            ])),
        const Text(
            'This is an offline-first MVP. No analytics, account sync, AI service, or purchase processor is connected.',
            style: TextStyle(color: QuestColors.muted, height: 1.5)),
      ]));
}
