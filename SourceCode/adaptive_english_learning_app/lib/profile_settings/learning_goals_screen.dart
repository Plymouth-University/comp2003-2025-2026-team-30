import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/user_profile_service.dart';
import '../widgets/translated_text.dart';

class LearningGoalsScreen extends StatefulWidget {
  const LearningGoalsScreen({super.key});

  @override
  State<LearningGoalsScreen> createState() => _LearningGoalsScreenState();
}

class _LearningGoalsScreenState extends State<LearningGoalsScreen> {
  static const List<String> _goalOptions = [
    'Daily conversation',
    'Work or school',
    'Travel',
    'Exams',
    'General fluency',
  ];

  static const List<String> _styleOptions = [
    'Visual',
    'Audio',
    'Practice first',
    'Grammar focused',
  ];

  final UserProfileService _userProfileService = UserProfileService();

  bool _isLoaded = false;
  bool _isSaving = false;
  String? _learningGoal;
  String? _learningStyle;
  String? _proficiencyLevel;

  void _hydrate(Map<String, dynamic> data) {
    if (_isLoaded) {
      return;
    }

    _learningGoal = data['learningGoal'] as String?;
    _learningStyle = data['learningStyle'] as String?;
    _proficiencyLevel = data['proficiencyLevel'] as String?;
    _isLoaded = true;
  }

  Future<void> _save(String uid) async {
    setState(() {
      _isSaving = true;
    });

    try {
      await _userProfileService.updateLearningSettings(
        uid: uid,
        proficiencyLevel: _proficiencyLevel,
        learningGoal: _learningGoal,
        learningStyle: _learningStyle,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Learning goals updated.')));
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update learning goals: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: TranslatedText('Please sign in to update your goals.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const TranslatedText('Learning Goals')),
      body: StreamBuilder(
        stream: _userProfileService.watchUserProfile(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() ?? <String, dynamic>{};
          _hydrate(data);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TranslatedText(
                  'Set your current learning goal and preferred practice style.',
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _learningGoal,
                  decoration: const InputDecoration(
                    label: TranslatedText('Learning goal'),
                    border: OutlineInputBorder(),
                  ),
                  items: _goalOptions
                      .map(
                        (goal) => DropdownMenuItem(
                          value: goal,
                          child: TranslatedText(goal),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _learningGoal = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _learningStyle,
                  decoration: const InputDecoration(
                    label: TranslatedText('Learning style'),
                    border: OutlineInputBorder(),
                  ),
                  items: _styleOptions
                      .map(
                        (style) => DropdownMenuItem(
                          value: style,
                          child: TranslatedText(style),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _learningStyle = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _proficiencyLevel,
                  decoration: const InputDecoration(
                    label: TranslatedText('Proficiency level'),
                    border: OutlineInputBorder(),
                  ),
                  items:
                      const [
                            'Beginner',
                            'Elementary',
                            'Intermediate',
                            'Upper Intermediate',
                            'Advanced',
                          ]
                          .map(
                            (level) => DropdownMenuItem(
                              value: level,
                              child: TranslatedText(level),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _proficiencyLevel = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _save(user.uid),
                    child: TranslatedText(
                      _isSaving ? 'Saving...' : 'Save goals',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
