import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/app_language_service.dart';
import '../widgets/main_navigation.dart';
import '../services/user_profile_service.dart';
import '../widgets/translated_text.dart';

class OnboardingScreen extends StatefulWidget {
  final String uid;

  const OnboardingScreen({super.key, required this.uid});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  final UserProfileService _userProfileService = UserProfileService();

  String? nativeLanguage;
  String? proficiencyLevel;
  String? learningGoal;
  String? learningStyle;

  bool _isSaving = false;

  Future<void> _finishOnboarding() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final answers = {
      'nativeLanguage': nativeLanguage,
      'knownLanguages': <String>[],
      'proficiencyLevel': proficiencyLevel,
      'learningGoal': learningGoal,
      'learningStyle': learningStyle,
      'preferredLocaleCode':
          AppLanguageService.instance.languageCodeForName(nativeLanguage) ??
          'en',
    };

    await _userProfileService.saveOnboardingProfile(
      uid: widget.uid,
      answers: answers,
    );

    await _userProfileService.logPlacementAttempt(
      uid: widget.uid,
      payload: {
        'answers': answers,
        'estimatedLevel': proficiencyLevel,
        'source': 'first_run_onboarding',
      },
    );

    if (!mounted) {
      return;
    }

    await AppLanguageService.instance.setLocaleFromProfile(answers);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (route) => false,
    );
  }

  void _nextPage() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _LanguageBackgroundStep(
                selectedNativeLanguage: nativeLanguage,
                onChanged: (native) {
                  setState(() {
                    nativeLanguage = native;
                  });
                },
                onNext: _nextPage,
                onSkip: _finishOnboarding,
              ),
              _SingleChoiceStep(
                title: 'English Proficiency',
                subtitle: 'Tell us where you are starting from',
                options: const [
                  'Beginner',
                  'Elementary',
                  'Intermediate',
                  'Upper Intermediate',
                  'Advanced',
                ],
                selectedValue: proficiencyLevel,
                onChanged: (value) {
                  setState(() {
                    proficiencyLevel = value;
                  });
                },
                onNext: _nextPage,
                onSkip: _finishOnboarding,
              ),
              _SingleChoiceStep(
                title: 'Learning Goals',
                subtitle: 'Choose what you want to improve first',
                options: const [
                  'Daily conversation',
                  'Work or school',
                  'Travel',
                  'Exams',
                  'General fluency',
                ],
                selectedValue: learningGoal,
                onChanged: (value) {
                  setState(() {
                    learningGoal = value;
                  });
                },
                onNext: _nextPage,
                onSkip: _finishOnboarding,
              ),
              _SingleChoiceStep(
                title: 'Learning Style',
                subtitle: 'Pick the format that helps you learn best',
                options: const [
                  'Visual',
                  'Audio',
                  'Practice first',
                  'Grammar focused',
                ],
                selectedValue: learningStyle,
                onChanged: (value) {
                  setState(() {
                    learningStyle = value;
                  });
                },
                onNext: _finishOnboarding,
                onSkip: _finishOnboarding,
                showFinish: true,
                isLoading: _isSaving,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageBackgroundStep extends StatelessWidget {
  final String? selectedNativeLanguage;
  final ValueChanged<String?> onChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _LanguageBackgroundStep({
    required this.selectedNativeLanguage,
    required this.onChanged,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final languages = const [
      'Spanish',
      'Mandarin',
      'Hindi',
      'Arabic',
      'French',
      'Portuguese',
      'Russian',
      'Japanese',
      'German',
      'Other',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEFF4F8),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const TranslatedText(
              'Language Background',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const TranslatedText(
              'Help us understand your linguistic background',
            ),
            const SizedBox(height: 30),
            const SizedBox(height: 4),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: languages.map((language) {
                final isSelected = selectedNativeLanguage == language;
                return ChoiceChip(
                  label: TranslatedText(language),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onChanged(language);
                    }
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: onSkip,
                  child: const TranslatedText('Skip'),
                ),
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: const TranslatedText('Next'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SingleChoiceStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool showFinish;
  final bool isLoading;

  const _SingleChoiceStep({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.onNext,
    required this.onSkip,
    this.showFinish = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return RadioGroup<String>(
      groupValue: selectedValue,
      onChanged: onChanged,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF4F8),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              TranslatedText(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TranslatedText(subtitle),
              const SizedBox(height: 30),
              ...options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RadioListTile<String>(
                    value: option,
                    title: TranslatedText(option),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: onSkip,
                    child: const TranslatedText('Skip'),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : onNext,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: TranslatedText(showFinish ? 'Finish' : 'Next'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
