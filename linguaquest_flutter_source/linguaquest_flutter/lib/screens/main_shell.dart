import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import 'main_screens.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _pages = [
    HomeScreen(),
    LearnScreen(),
    GameZoneScreen(),
    ProgressScreen(),
    ProfileScreen()
  ];
  static const _destinations = [
    NavigationDestination(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore_rounded),
        label: 'Home'),
    NavigationDestination(
        icon: Icon(Icons.menu_book_outlined),
        selectedIcon: Icon(Icons.menu_book_rounded),
        label: 'Learn'),
    NavigationDestination(
        icon: Icon(Icons.sports_esports_outlined),
        selectedIcon: Icon(Icons.sports_esports_rounded),
        label: 'Games'),
    NavigationDestination(
        icon: Icon(Icons.insights_outlined),
        selectedIcon: Icon(Icons.insights_rounded),
        label: 'Progress'),
    NavigationDestination(
        icon: Icon(Icons.account_circle_outlined),
        selectedIcon: Icon(Icons.account_circle_rounded),
        label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: IndexedStack(index: state.tabIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.tabIndex,
        destinations: _destinations,
        onDestinationSelected: state.selectTab,
      ),
    );
  }
}
