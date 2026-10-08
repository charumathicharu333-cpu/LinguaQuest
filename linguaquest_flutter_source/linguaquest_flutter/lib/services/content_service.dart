import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/quest_models.dart';

class ContentService {
  static const _files = {
    'Science': 'science',
    'Geography': 'geography',
    'General Knowledge': 'gk',
    'Logic': 'logic',
  };

  Future<List<QuestQuestion>> questions(String category,
      {String ageGroup = '11-14'}) async {
    final file = _files[category];
    if (file == null) return const [];
    final decoded =
        jsonDecode(await rootBundle.loadString('assets/data/$file.json'))
            as Map<String, dynamic>;
    final questions = (decoded['questions'] as List<dynamic>)
        .map((item) =>
            QuestQuestion.fromJson(item as Map<String, dynamic>, category))
        .toList();
    final count = switch (ageGroup) {
      '6-10' => 6,
      '11-14' => 10,
      '15-18' => 15,
      _ => questions.length
    };
    return questions.take(count).toList();
  }

  Future<Map<String, dynamic>> languagePack(String code) async {
    final file =
        switch (code) { 'hi' => 'hindi', 'ja' => 'japanese', _ => 'english' };
    return jsonDecode(await rootBundle.loadString('assets/data/$file.json'))
        as Map<String, dynamic>;
  }
}
