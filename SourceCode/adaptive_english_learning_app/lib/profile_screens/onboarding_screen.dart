import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/main_navigation.dart';
import '../services/user_profile_service.dart';

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
  List<String> knownLanguages = [];

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
      'knownLanguages': knownLanguages,
      'proficiencyLevel': proficiencyLevel,
      'learningGoal': learningGoal,
      'learningStyle': learningStyle,
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
                selectedKnownLanguages: knownLanguages,
                onChanged: (native, known) {
                  setState(() {
                    nativeLanguage = native;
                    knownLanguages = known;
                  });
                },
                onNext: _nextPage,
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
                showFinish: true,
                isLoading: _isSaving,
              ),
            ],
          ),
          Align(
            alignment: const Alignment(0, 0.9),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _controller.jumpToPage(3);
                    },
                    child: const Text('Skip'),
                  ),
                  if (_isSaving)
                    const CircularProgressIndicator()
                  else
                    const SizedBox(width: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageBackgroundStep extends StatelessWidget {
  final String? selectedNativeLanguage;
  final List<String> selectedKnownLanguages;
  final ValueChanged2 onChanged;
  final VoidCallback onNext;

  const _LanguageBackgroundStep({
    required this.selectedNativeLanguage,
    required this.selectedKnownLanguages,
    required this.onChanged,
    required this.onNext,
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
            const Text(
              'Language Background',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Help us understand your linguistic background'),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select your native language',
                border: OutlineInputBorder(),
              ),
              initialValue: selectedNativeLanguage,
              items: languages
                  .map(
                    (language) => DropdownMenuItem(
                      value: language,
                      child: Text(language),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                onChanged(value, selectedKnownLanguages);
              },
            ),
            const SizedBox(height: 25),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: languages.map((language) {
                final isSelected = selectedKnownLanguages.contains(language);
                return ChoiceChip(
                  label: Text(language),
                  selected: isSelected,
                  onSelected: (selected) {
                    final updated = List<String>.from(selectedKnownLanguages);
                    if (selected) {
                      if (!updated.contains(language)) {
                        updated.add(language);
                      }
                    } else {
                      updated.remove(language);
                    }
                    onChanged(selectedNativeLanguage, updated);
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text('Next'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

typedef ValueChanged2 = void Function(String? primary, List<String> secondary);

class _SingleChoiceStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final VoidCallback onNext;
  final bool showFinish;
  final bool isLoading;

  const _SingleChoiceStep({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.onNext,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(subtitle),
              const SizedBox(height: 30),
              ...options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RadioListTile<String>(
                    value: option,
                    title: Text(option),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: Text(showFinish ? 'Finish' : 'Next'),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
