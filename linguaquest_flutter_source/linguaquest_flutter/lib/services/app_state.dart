import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../models/quest_models.dart';
import 'database_service.dart';
import 'achievement_service.dart';
import 'progress_service.dart';
import 'streak_service.dart';
import 'xp_service.dart';

class AppState extends ChangeNotifier {
  AppState(this.database);

  final DatabaseService database;
  int tabIndex = 0;
  int xp = 0;
  int lessonsCompleted = 0;
  int correctAnswers = 0;
  int attempts = 0;
  int badges = 0;
  int streak = 0;
  int _sessionMinutes = 0;
  String ageGroup = '11-14';
  String language = 'en';
  bool onboardingComplete = false;
  bool dailyQuestComplete = false;

  int get level => ProgressService.levelForXp(xp);
  double get levelProgress => ProgressService.levelProgress(xp);
  String get languageName =>
      switch (language) { 'hi' => 'Hindi', 'ja' => 'Japanese', _ => 'English' };
  int get learningMinutes => (_sessionMinutes + lessonsCompleted * 3 + attempts)
      .clamp(0, 9999)
      .toInt();

  Future<void> initialize() async {
    onboardingComplete =
        await database.setting('onboarding_complete', 'false') == 'true';
    ageGroup = await database.setting('age_group', '11-14');
    language = await database.setting('language', 'en');
    final summary = await database.summary();
    xp = summary['xp'] as int? ?? 0;
    lessonsCompleted = summary['lessons'] as int? ?? 0;
    correctAnswers = summary['correct'] as int? ?? 0;
    attempts = summary['attempts'] as int? ?? 0;
    badges = summary['badges'] as int? ?? 0;
    streak = summary['streak'] as int? ?? 0;
    dailyQuestComplete = await database.ensureDailyChallenge() == 1;
    notifyListeners();
  }

  void selectTab(int index) {
    tabIndex = index;
    notifyListeners();
  }

  Future<void> finishOnboarding(
      String selectedAge, String selectedLanguage) async {
    ageGroup = selectedAge;
    language = selectedLanguage;
    onboardingComplete = true;
    await database.saveSetting('age_group', ageGroup);
    await database.saveSetting('language', language);
    await database.saveSetting('onboarding_complete', 'true');
    final db = await database.database;
    await db.insert(
        'age_profiles', {'user_id': 'local-player', 'age_group': ageGroup},
        conflictAlgorithm: ConflictAlgorithm.replace);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    language = code;
    await database.saveSetting('language', code);
    notifyListeners();
  }

  Future<void> answer(QuestQuestion question, int selectedIndex) async {
    final correct = ProgressService.isCorrect(question, selectedIndex);
    await database.recordProgress(
        activityId: question.id, type: 'question', correct: correct);
    if (correct) {
      await XPService.award(database, ProgressService.xpForCorrectAnswer());
      xp += XPService.correctAnswer;
      correctAnswers++;
    }
    attempts++;
    streak = await StreakService(database).recordLearningDay();
    badges = await AchievementService(database)
        .refresh(xp: xp, correctAnswers: correctAnswers);
    notifyListeners();
  }

  Future<void> completeLesson(String lessonId) async {
    final db = await database.database;
    final alreadyComplete = await database.hasCompletedLesson(lessonId);
    if (!alreadyComplete) {
      await db.rawInsert(
          '''INSERT INTO user_progress(user_id, activity_id, activity_type, completed, correct_count, attempts, updated_at)
        VALUES('local-player', ?, 'lesson', 1, 0, 1, ?)
        ON CONFLICT(user_id, activity_id, activity_type) DO UPDATE SET completed = 1, updated_at = excluded.updated_at''',
          [lessonId, DateTime.now().toIso8601String()]);
      await XPService.award(database, XPService.lessonComplete);
      xp += XPService.lessonComplete;
      lessonsCompleted++;
      _sessionMinutes += 2;
    }
    if (!dailyQuestComplete) {
      await database.completeDailyChallenge();
      dailyQuestComplete = true;
      await XPService.award(database, XPService.dailyQuest);
      xp += XPService.dailyQuest;
    }
    await database.ensureDailyChallenge();
    streak = await StreakService(database).recordLearningDay();
    badges = await AchievementService(database)
        .refresh(xp: xp, correctAnswers: correctAnswers, lessonCompleted: true);
    notifyListeners();
  }
}
