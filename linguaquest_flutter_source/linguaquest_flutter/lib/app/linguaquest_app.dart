import 'package:flutter/material.dart';

import 'theme.dart';
import '../screens/splash_screen.dart';

class LinguaQuestApp extends StatelessWidget {
  const LinguaQuestApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'LinguaQuest',
        debugShowCheckedModeBanner: false,
        theme: buildQuestTheme(),
        home: const SplashScreen(),
      );
}
