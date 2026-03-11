import 'package:flutter/material.dart';
import 'language_background_screen.dart';
// import other steps here

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  void nextPage() {
    if (currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Finished onboarding
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },
        children: [
          LanguageBackgroundScreen(onNext: nextPage),
          // Add other screens here
        ],
      ),
    );
  }
}