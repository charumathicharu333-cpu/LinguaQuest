import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../services/app_state.dart';
import '../widgets/quest_widgets.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String age = '11-14';
  String language = 'en';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('Set your trail',
                style: TextStyle(fontWeight: FontWeight.w900))),
        body: ScreenColumn(children: [
          Text('Made for your kind of curious.',
              style: Theme.of(context).textTheme.headlineMedium),
          const Text(
              'Choose an age range and a language. No real name or account needed.',
              style: TextStyle(color: QuestColors.muted, height: 1.5)),
          const Text('YOUR AGE RANGE',
              style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w900,
                  color: QuestColors.muted)),
          Wrap(spacing: 9, runSpacing: 9, children: [
            for (final option in [
              ('6-10', 'Kids'),
              ('11-14', 'Junior'),
              ('15-18', 'Teen'),
              ('18+', 'Young adult')
            ])
              ChoiceChip(
                  label: Text('${option.$2} · ${option.$1}'),
                  selected: age == option.$1,
                  onSelected: (_) => setState(() => age = option.$1))
          ]),
          const Text('YOUR FIRST LANGUAGE',
              style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w900,
                  color: QuestColors.muted)),
          for (final item in [
            ('en', '🇬🇧', 'English', 'Start with everyday words'),
            ('hi', '🇮🇳', 'Hindi', 'Learn with familiar sounds'),
            ('ja', '🇯🇵', 'Japanese', 'Explore a new writing system')
          ])
            QuestCard(
              color: language == item.$1 ? QuestColors.mint : Colors.white,
              onTap: () => setState(() => language = item.$1),
              child: Row(children: [
                Text(item.$2, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(item.$3,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 16)),
                      Text(item.$4,
                          style: const TextStyle(color: QuestColors.muted))
                    ])),
                Icon(
                    language == item.$1
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: QuestColors.teal)
              ]),
            ),
          GameButton(
              label: 'Start exploring',
              onPressed: () async {
                await context.read<AppState>().finishOnboarding(age, language);
                if (context.mounted)
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainShell()),
                      (_) => false);
              }),
          const Center(
              child: Text('Change these choices any time in Settings.',
                  style: TextStyle(color: QuestColors.muted))),
        ]),
      );
}
