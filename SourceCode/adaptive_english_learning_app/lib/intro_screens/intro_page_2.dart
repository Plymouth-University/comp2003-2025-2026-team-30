import 'package:flutter/material.dart';

import '../widgets/translated_text.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 80, color: Colors.white),
          const SizedBox(height: 30),
          const TranslatedText(
            'AI-Powered Personalization',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const TranslatedText(
            'Lessons adapt to your proficiency level and learning style, helping you progress faster and more confidently.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Icon(Icons.translate, size: 60, color: Colors.white),
          const SizedBox(height: 12),
          const TranslatedText(
            'Multilingual Support\nLearn English with cultural context in your native language.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
