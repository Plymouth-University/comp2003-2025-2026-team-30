import 'package:flutter/material.dart';

import 'ai_text_practice_screen.dart';
import 'pronunciation_practice_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with "Practice" title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Practice',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // Quick Practice Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Practice',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Build your skills with short, focused practice sessions. Each activity takes just 5-10 minutes!',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24.0),

            // Choose an Activity Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Choose an Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 16.0),

            // Activity Cards Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                childAspectRatio: 1.1,
                children: [
                  _ActivityCard(
                    title: 'Pronunciation Practice',
                    emoji: '🎤',
                    color: const Color(0xFFE97B3A),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PronunciationPracticeScreen(),
                        ),
                      );
                    },
                  ),
                  _ActivityCard(
                    title: 'Vocabulary Builder',
                    emoji: '📚',
                    color: const Color(0xFF52B788),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AiTextPracticeScreen(
                            activityType: 'vocabulary_builder',
                            title: 'Vocabulary Builder',
                            prompt:
                                'Write 5 useful sentences using the words: curious, improve, practice, fluent, and target.',
                            hint: 'Type your five sentences here.',
                          ),
                        ),
                      );
                    },
                  ),
                  _ActivityCard(
                    title: 'Grammar Tips',
                    emoji: '💡',
                    color: const Color(0xFF3B82F6),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AiTextPracticeScreen(
                            activityType: 'grammar_tips',
                            title: 'Grammar Tips',
                            prompt:
                                'Explain the difference between present simple and present continuous in your own words.',
                            hint: 'Type your explanation here.',
                          ),
                        ),
                      );
                    },
                  ),
                  _ActivityCard(
                    title: 'Daily Quiz',
                    emoji: '🎯',
                    color: const Color(0xFFA855F7),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AiTextPracticeScreen(
                            activityType: 'daily_quiz',
                            title: 'Daily Quiz',
                            prompt:
                                'Answer in 3-4 sentences: What is one habit that helps you learn English every day?',
                            hint: 'Type your quiz answer here.',
                          ),
                        ),
                      );
                    },
                  ),
                  _ActivityCard(
                    title: 'Listening Challenge',
                    emoji: '🎧',
                    color: const Color(0xFF3B82F6),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AiTextPracticeScreen(
                            activityType: 'listening_challenge',
                            title: 'Listening Challenge',
                            prompt:
                                'Listen to a short audio clip in the full version, then summarize the main idea here.',
                            hint: 'Type your summary here.',
                          ),
                        ),
                      );
                    },
                  ),
                  _ActivityCard(
                    title: 'Writing Practice',
                    emoji: '✏️',
                    color: const Color(0xFFA855F7),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AiTextPracticeScreen(
                            activityType: 'writing_practice',
                            title: 'Writing Practice',
                            prompt:
                                'Write a short paragraph about your favorite place and why it matters to you.',
                            hint: 'Type your paragraph here.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24.0),

            // More Activities Coming Soon Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey.shade200, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('🚀', style: TextStyle(fontSize: 32.0)),
                    const SizedBox(height: 12.0),
                    Text(
                      'More Activities Coming Soon!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "We're working on exciting new practice features to help you learn faster.",
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 10.0,
                        ),
                      ),
                      child: Text(
                        'Stay Updated',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24.0),

            // Keep Your Streak Going Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.orange.shade300, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Text('🔥', style: TextStyle(fontSize: 24.0)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keep Your Streak Going!',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Complete any practice activity today to maintain your 7-day streak.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.title,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40.0)),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
