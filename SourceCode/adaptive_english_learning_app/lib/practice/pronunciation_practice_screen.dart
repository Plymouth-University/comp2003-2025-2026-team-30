import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/ai_tutor_service.dart';
import '../services/learning_firestore_service.dart';
import '../services/speech_recognition_service.dart';
import '../services/user_profile_service.dart';

class PronunciationPracticeScreen extends StatefulWidget {
  const PronunciationPracticeScreen({super.key});

  @override
  State<PronunciationPracticeScreen> createState() =>
      _PronunciationPracticeScreenState();
}

class _PronunciationPracticeScreenState
    extends State<PronunciationPracticeScreen> {
  final SpeechRecognitionService _speechService = SpeechRecognitionService();
  final AiTutorService _aiTutorService = AiTutorService();
  final LearningFirestoreService _learningService = LearningFirestoreService();
  final UserProfileService _userProfileService = UserProfileService();
  final TextEditingController _manualTranscriptController =
      TextEditingController();

  final List<String> _prompts = const [
    'Introduce yourself in two sentences.',
    'Describe your daily routine.',
    'Ask for directions to the nearest train station.',
    'Talk about your favorite meal and why you like it.',
  ];

  int _promptIndex = 0;
  bool _isListening = false;
  bool _isEvaluating = false;
  String _transcript = '';
  Map<String, dynamic>? _evaluation;
  String? _errorMessage;

  List<String> _buildPrompts(Map<String, dynamic> profileData) {
    final level = (profileData['proficiencyLevel'] as String? ?? '')
        .toLowerCase();
    final goal = (profileData['learningGoal'] as String? ?? '').toLowerCase();

    if (goal.contains('travel')) {
      return const [
        'Ask for help at an airport in two sentences.',
        'Explain how to find your hotel from the train station.',
        'Describe what you need when checking into a hotel.',
        'Practice asking for directions politely.',
      ];
    }

    if (goal.contains('work') ||
        goal.contains('school') ||
        goal.contains('exam')) {
      return const [
        'Introduce yourself in a formal interview.',
        'Describe your strengths in two sentences.',
        'Explain a project you completed recently.',
        'Talk about a goal you have for this year.',
      ];
    }

    if (level.contains('beginner') || level.contains('elementary')) {
      return const [
        'Say hello and introduce yourself.',
        'Tell me about your family in one or two sentences.',
        'Describe your favorite food.',
        'Talk about your daily routine briefly.',
      ];
    }

    return _prompts;
  }

  @override
  void dispose() {
    _manualTranscriptController.dispose();
    _speechService.stopListening();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    setState(() {
      _errorMessage = null;
    });

    if (_isListening) {
      await _speechService.stopListening();
      if (!mounted) return;
      setState(() {
        _isListening = false;
      });
      return;
    }

    try {
      await _speechService.startListening(
        onResult: (transcript) {
          if (!mounted) return;
          setState(() {
            _transcript = transcript;
            _manualTranscriptController.text = transcript;
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _isListening = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _evaluateAttempt(
    Map<String, dynamic> profileData,
    String prompt,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final transcript = _manualTranscriptController.text.trim().isNotEmpty
        ? _manualTranscriptController.text.trim()
        : _transcript.trim();

    if (transcript.isEmpty) {
      setState(() {
        _errorMessage = 'Record or type a response before evaluating.';
      });
      return;
    }

    setState(() {
      _isEvaluating = true;
      _errorMessage = null;
    });

    try {
      final evaluation = await _aiTutorService.evaluateSpeakingAttempt(
        prompt: prompt,
        transcript: transcript,
        profileData: profileData,
      );

      await _learningService.recordSpeakingAttempt(
        uid: user.uid,
        prompt: prompt,
        transcript: transcript,
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

  void _nextPrompt() {
    setState(() {
      _promptIndex = (_promptIndex + 1) % _prompts.length;
      _transcript = '';
      _evaluation = null;
      _manualTranscriptController.clear();
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
        body: Center(child: Text('Please sign in to start practice.')),
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
        final prompts = _buildPrompts(profileData);
        final prompt = prompts[_promptIndex % prompts.length];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Pronunciation Practice'),
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
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFCD9B6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Speak, then get AI feedback',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(prompt, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        'Matched to ${profileData['proficiencyLevel'] ?? 'your current level'} and ${profileData['learningGoal'] ?? 'your goal'}.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _toggleListening,
                        icon: Icon(_isListening ? Icons.stop : Icons.mic),
                        label: Text(_isListening ? 'Stop Mic' : 'Start Mic'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isListening
                              ? Colors.redAccent
                              : const Color(0xFF2F80ED),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isEvaluating
                            ? null
                            : () => _evaluateAttempt(profileData, prompt),
                        icon: const Icon(Icons.auto_awesome),
                        label: Text(
                          _isEvaluating ? 'Evaluating...' : 'Evaluate',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _manualTranscriptController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'Transcript',
                    hintText:
                        'Your speech transcript appears here or type it manually',
                    border: const OutlineInputBorder(),
                    helperText:
                        'Practice mode is tailored to ${profileData['learningStyle'] ?? 'your learning style'}.',
                  ),
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
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
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
                          'Suggested phrasing',
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
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        _nextPrompt();
                        setState(() {
                          _manualTranscriptController.clear();
                          _evaluation = null;
                          _errorMessage = null;
                        });
                      },
                      child: const Text('Try another prompt'),
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
