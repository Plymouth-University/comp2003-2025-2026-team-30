import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/ai_tutor_service.dart';
import '../services/learning_firestore_service.dart';
import '../services/user_profile_service.dart';
import '../widgets/translated_text.dart';

class AiTextPracticeScreen extends StatefulWidget {
  final String activityType;
  final String title;
  final String prompt;
  final String hint;

  const AiTextPracticeScreen({
    super.key,
    required this.activityType,
    required this.title,
    required this.prompt,
    required this.hint,
  });

  @override
  State<AiTextPracticeScreen> createState() => _AiTextPracticeScreenState();
}

class _AiTextPracticeScreenState extends State<AiTextPracticeScreen> {
  final AiTutorService _aiTutorService = AiTutorService();
  final LearningFirestoreService _learningService = LearningFirestoreService();
  final UserProfileService _userProfileService = UserProfileService();
  final TextEditingController _responseController = TextEditingController();

  bool _isEvaluating = false;
  Map<String, dynamic>? _evaluation;
  String? _errorMessage;

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _evaluateResponse(
    Map<String, dynamic> profileData,
    String prompt,
    String hint,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final responseText = _responseController.text.trim();
    if (responseText.isEmpty) {
      setState(() {
        _errorMessage = 'Write a response before evaluating.';
      });
      return;
    }

    setState(() {
      _isEvaluating = true;
      _errorMessage = null;
    });

    try {
      final evaluation = await _aiTutorService.evaluateTextAttempt(
        activityType: widget.activityType,
        prompt: prompt,
        responseText: responseText,
        profileData: profileData,
      );

      await _learningService.recordPracticeAttempt(
        uid: user.uid,
        activityType: widget.activityType,
        prompt: prompt,
        responseText: responseText,
        evaluation: evaluation,
      );

      if (!mounted) return;

      setState(() {
        _evaluation = evaluation;
        _isEvaluating = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Evaluation failed: $error';
        _isEvaluating = false;
      });
    }
  }

  String _buildPrompt(Map<String, dynamic> profileData) {
    final level = (profileData['proficiencyLevel'] as String?) ?? 'Learner';
    final goal = (profileData['learningGoal'] as String?) ?? 'general fluency';
    return '${widget.prompt}\n\nRecommended for $level focused on $goal.';
  }

  String _buildHint(Map<String, dynamic> profileData) {
    final style = (profileData['learningStyle'] as String?) ?? 'balanced';
    return '${widget.hint} ($style practice mode)';
  }

  void _reset() {
    setState(() {
      _evaluation = null;
      _errorMessage = null;
      _responseController.clear();
    });
  }

  bool _isLocalFallback(Map<String, dynamic> evaluation) {
    return evaluation['isFallback'] == true ||
        evaluation['source'] == 'local-fallback';
  }

  String _sectionTitle(Map<String, dynamic> evaluation) {
    return _isLocalFallback(evaluation) ? 'Local practice mode' : 'AI feedback';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: TranslatedText('Please sign in to start practice.')),
      );
    }

    return StreamBuilder(
      stream: _userProfileService.watchUserProfile(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profileData = snapshot.data?.data() ?? <String, dynamic>{};
        final prompt = _buildPrompt(profileData);
        final hint = _buildHint(profileData);

        return Scaffold(
          appBar: AppBar(
            title: TranslatedText(widget.title),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TranslatedText(
                        'AI-guided practice',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Keep English: this is the learner's practice prompt
                      Text(prompt),
                      const SizedBox(height: 8),
                      TranslatedText(
                        'Tailored to ${profileData['proficiencyLevel'] ?? 'your current level'} and ${profileData['learningGoal'] ?? 'your goal'}.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _responseController,
                  minLines: 4,
                  maxLines: 8,
                  decoration: InputDecoration(
                    label: TranslatedText(widget.title),
                    hintText: hint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isEvaluating
                            ? null
                            : () =>
                                  _evaluateResponse(profileData, prompt, hint),
                        icon: const Icon(Icons.auto_awesome),
                        label: TranslatedText(
                          _isEvaluating ? 'Evaluating...' : 'Ask AI to Review',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _reset,
                      child: const TranslatedText('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                if (_evaluation != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _sectionTitle(_evaluation!),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _ScoreChip(score: _evaluation!['score']),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'What to say instead',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text('${_evaluation!['correctedTranscript']}'),
                        const SizedBox(height: 8),
                        const Text(
                          'Next step',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text('${_evaluation!['nextStep']}'),
                        const SizedBox(height: 12),
                        if (_isLocalFallback(_evaluation!))
                          Text(
                            'Local practice mode is active while the AI service is unavailable.',
                            style: TextStyle(color: Colors.orange.shade800),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.score});

  final dynamic score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FDF5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Score ${score ?? 0}',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF047857),
        ),
      ),
    );
  }
}
