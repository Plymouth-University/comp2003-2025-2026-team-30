import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../lessons/lessons_screen.dart';
import '../practice/practice_screen.dart';
import '../progress/progress_screen.dart';
import '../profile_settings/profile_screen.dart';
import '../services/app_language_service.dart';
import '../services/app_translation_service.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  late final List<String> _baseLabels;
  Future<List<String>>? _translatedLabelsFuture;
  Locale? _lastLocale;

  void _refreshLabels() {
    final locale =
        AppLanguageService.instance.localeNotifier.value ?? const Locale('en');
    if (_lastLocale == locale && _translatedLabelsFuture != null) {
      return;
    }

    _lastLocale = locale;
    _translatedLabelsFuture = AppTranslationService.instance.translateMany(
      _baseLabels,
      targetLocale: locale,
    );
  }

  @override
  void initState() {
    super.initState();
    _baseLabels = const ['Home', 'Lessons', 'Practice', 'Progress', 'Profile'];
    _pages = [
      HomeScreen(onGoToLessons: _goToLessonsTab),
      const LessonsScreen(),
      const PracticeScreen(),
      ProgressScreen(),
      const ProfileScreen(),
    ];
    _refreshLabels();
    AppLanguageService.instance.localeNotifier.addListener(_handleLocaleChange);
  }

  @override
  void dispose() {
    AppLanguageService.instance.localeNotifier.removeListener(
      _handleLocaleChange,
    );
    super.dispose();
  }

  void _handleLocaleChange() {
    setState(() {
      _refreshLabels();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _goToLessonsTab() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _translatedLabelsFuture,
      initialData: _baseLabels,
      builder: (context, snapshot) {
        final labels = snapshot.data ?? _baseLabels;
        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: _pages),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: labels[0],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.menu_book_outlined),
                activeIcon: const Icon(Icons.menu_book),
                label: labels[1],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.fitness_center_outlined),
                activeIcon: const Icon(Icons.fitness_center),
                label: labels[2],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.show_chart_outlined),
                activeIcon: const Icon(Icons.show_chart),
                label: labels[3],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: labels[4],
              ),
            ],
          ),
        );
      },
    );
  }
}
