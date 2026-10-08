import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:linguaquest/models/quest_models.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:linguaquest/screens/game_screens.dart';
import 'package:linguaquest/screens/lesson_screen.dart';
import 'package:linguaquest/screens/main_screens.dart';
import 'package:linguaquest/services/app_state.dart';
import 'package:linguaquest/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<AppState> readyState() async {
    final state = TestAppState();
    state.onboardingComplete = true;
    return state;
  }

  Future<void> show(WidgetTester tester, AppState state, Widget child) async {
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: state, child: MaterialApp(home: Scaffold(body: child))));
    await tester.pumpAndSettle();
  }

  testWidgets('home renders the map and offline status', (tester) async {
    final state = await readyState();
    await show(tester, state, const HomeScreen());
    expect(find.text('Your adventure map'), findsOneWidget);
    expect(find.text('READY OFFLINE'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Welcome Village'), 250);
    expect(find.text('Welcome Village'), findsOneWidget);
  });

  testWidgets('lesson loads its first local vocabulary card', (tester) async {
    final state = await readyState();
    await show(tester, state, const LessonScreen());
    expect(find.text('A few useful words'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('quiz accepts an answer and gives kind feedback', (tester) async {
    final state = await readyState();
    await show(
        tester,
        state,
        const GamePlayScreen(
            title: 'Quiz',
            category: 'Science',
            gameType: 'Multiple Choice Quiz'));
    await tester.tap(find.text('The Sun'));
    await tester.pumpAndSettle();
    expect(find.textContaining('That is right!'), findsOneWidget);
    expect(state.xp, 10);
  });

  testWidgets('progress screen shows levels and badges', (tester) async {
    final state = await readyState();
    await show(tester, state, const ProgressScreen());
    expect(find.text('Your discoveries'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Your badges'), 350);
    expect(find.text('Your badges'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('First Footprints'), 250);
    expect(find.text('First Footprints'), findsOneWidget);
  });
}

class TestAppState extends AppState {
  TestAppState() : super(TestDatabaseService());

  @override
  Future<void> answer(QuestQuestion question, int selectedIndex) async {
    if (question.isCorrect(selectedIndex)) {
      xp += 10;
      correctAnswers++;
    }
    attempts++;
    notifyListeners();
  }
}

class TestDatabaseService extends DatabaseService {
  @override
  Future<List<Map<String, Object?>>> achievements() async => [
        {
          'id': 'first-steps',
          'title': 'First Footprints',
          'description': 'Finish your first lesson',
          'emoji': '👣',
          'threshold': 1,
          'unlocked': 0,
        },
      ];
}
