import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../services/app_state.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.watch<AppState>().onboardingComplete) return const MainShell();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
              Color(0xFFE9F4E8),
              Color(0xFFF7F8F3),
              Color(0xFFFFE4D7)
            ])),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Center(
                  child: Container(
                    width: 176,
                    height: 176,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .8),
                        shape: BoxShape.circle),
                    child: const Center(
                        child: Text('🌍', style: TextStyle(fontSize: 82))),
                  ),
                ),
                const SizedBox(height: 34),
                Text('LINGUAQUEST',
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(letterSpacing: 1.4)),
                const SizedBox(height: 8),
                Text('Turn Screen Time Into Learning Time.',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                Text(
                    'A little curiosity can take you anywhere. Pick a path, learn something new, and explore at your own pace.',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 22),
                const Row(children: [
                  Icon(Icons.wifi_off_rounded,
                      color: QuestColors.teal, size: 18),
                  SizedBox(width: 8),
                  Text('Your first adventures work offline',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, color: QuestColors.teal))
                ]),
                const Spacer(),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const OnboardingScreen())),
                        child: const Text('Choose your adventure'))),
                const SizedBox(height: 12),
                const Center(
                    child: Text('Free to explore · No account needed',
                        style: TextStyle(
                            color: QuestColors.muted,
                            fontWeight: FontWeight.w700))),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
