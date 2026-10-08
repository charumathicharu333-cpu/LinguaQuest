import 'package:flutter/material.dart';

abstract final class QuestColors {
  static const ink = Color(0xFF18354B);
  static const muted = Color(0xFF718594);
  static const paper = Color(0xFFF7F8F3);
  static const teal = Color(0xFF137C76);
  static const mint = Color(0xFFD8F0E7);
  static const lime = Color(0xFFC9E67A);
  static const coral = Color(0xFFF18F70);
  static const gold = Color(0xFFFFD477);
  static const blue = Color(0xFF8CC9E8);
  static const lilac = Color(0xFFD8CDF3);
}

ThemeData buildQuestTheme() => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: QuestColors.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: QuestColors.teal,
        primary: QuestColors.teal,
        secondary: QuestColors.coral,
        surface: Colors.white,
      ),
      fontFamily: 'Nunito',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 30,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: QuestColors.ink),
        headlineMedium: TextStyle(
            fontSize: 23,
            height: 1.15,
            fontWeight: FontWeight.w900,
            color: QuestColors.ink),
        titleLarge: TextStyle(
            fontSize: 19, fontWeight: FontWeight.w900, color: QuestColors.ink),
        titleMedium: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800, color: QuestColors.ink),
        bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.45,
            fontWeight: FontWeight.w600,
            color: QuestColors.ink),
        bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: QuestColors.muted),
      ),
      appBarTheme: const AppBarTheme(
          backgroundColor: QuestColors.paper,
          foregroundColor: QuestColors.ink,
          elevation: 0),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: QuestColors.mint,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w900
                  : FontWeight.w700,
              color: states.contains(WidgetState.selected)
                  ? QuestColors.teal
                  : QuestColors.muted,
            )),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 54),
          backgroundColor: QuestColors.teal,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
