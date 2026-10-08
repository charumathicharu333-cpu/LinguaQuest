import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/linguaquest_app.dart';
import 'services/app_state.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState(DatabaseService());
  await state.initialize();
  runApp(ChangeNotifierProvider.value(
      value: state, child: const LinguaQuestApp()));
}
