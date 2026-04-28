import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/ai_tutor_service.dart';
import '../services/learning_firestore_service.dart';
import '../widgets/translated_text.dart';

class LessonSectionScreen extends StatefulWidget {
  final Map<String, dynamic> lesson;
  final int currentIndex;

  const LessonSectionScreen({
    super.key,
    required this.lesson,
    required this.currentIndex,
  });

  @override
  State<LessonSectionScreen> createState() => _LessonSectionScreenState();
}

class _LessonSectionScreenState extends State<LessonSectionScreen> {
  static final Map<String, Color> skillColors = {
    "Listening": Colors.green,
    "Speaking": Colors.orange,
    "Reading": Colors.blue,
    "Writing": Colors.purple,
  };

  final AiTutorService _aiService = AiTutorService();
  final LearningFirestoreService _learningService = LearningFirestoreService();
  final SpeechRecognitionService _speechService = SpeechRecognitionService();
  final TextEditingController _controller = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _aiResult;

  // Speaking-specific state
  String _transcript = '';
  bool _isRecording = false;

  @override
  void dispose() {
    _controller.dispose();
    if (_isRecording) {
      _speechService.stopListening();
    }
    super.dispose();
  }

  Future<void> _saveProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final outline = (widget.lesson["outline"] as List?) ?? const [];
    await _learningService.recordLessonSectionCompletion(
      uid: user.uid,
      lesson: widget.lesson,
      sectionIndex: widget.currentIndex,
      totalSections: outline.length,
    );
  }

  Future<void> _submitTextForFeedback({
    required String activityType,
    required String prompt,
  }) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _aiResult = null;
    });

    try {
      final result = await _aiService.evaluateTextAttempt(
        activityType: activityType,
        prompt: prompt,
        responseText: text,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _learningService.recordPracticeAttempt(
          uid: user.uid,
          activityType: activityType,
          prompt: prompt,
          responseText: text,
          evaluation: result,
        );
      }

      if (mounted) {
        setState(() {
          _aiResult = result;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitSpeakingForFeedback(String prompt) async {
    if (_transcript.isEmpty) return;

    setState(() {
      _isLoading = true;
      _aiResult = null;
    });

    try {
      final result = await _aiService.evaluateSpeakingAttempt(
        prompt: prompt,
        transcript: _transcript,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _learningService.recordSpeakingAttempt(
          uid: user.uid,
          prompt: prompt,
          transcript: _transcript,
          evaluation: result,
        );
      }

      if (mounted) {
        setState(() {
          _aiResult = result;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleRecording(String prompt) async {
    if (_isRecording) {
      await _speechService.stopListening();
      setState(() => _isRecording = false);
      if (_transcript.isNotEmpty) {
        _submitSpeakingForFeedback(prompt);
      }
    } else {
      setState(() {
        _transcript = '';
        _isRecording = true;
        _aiResult = null;
      });
      try {
        await _speechService.startListening(
          onResult: (text) {
            if (mounted) setState(() => _transcript = text);
          },
        );
      } catch (_) {
        if (mounted) setState(() => _isRecording = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final outline = (widget.lesson["outline"] as List<dynamic>?) ?? const [];
    final section = outline[widget.currentIndex] as Map<String, dynamic>;
    final color = skillColors[widget.lesson["skill"]] ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: TranslatedText(section["title"]),
        backgroundColor: color,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Progress bar
            LinearProgressIndicator(
              value: (widget.currentIndex + 1) / outline.length,
              color: color,
              backgroundColor: Colors.grey[300],
            ),

            const SizedBox(height: 8),

            TranslatedText(
              "Section ${currentIndex + 1} of ${outline.length}",
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 20),

            /// TITLE
            TranslatedText(
              section["title"],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                child: _buildSectionContent(section, color),
              ),
            ),

            const SizedBox(height: 10),

            /// Previous / Next navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.currentIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonSectionScreen(
                            lesson: widget.lesson,
                            currentIndex: widget.currentIndex - 1,
                          ),
                        ),
                      );
                    },
                    child: const TranslatedText("Previous"),
                  )
                else
                  const SizedBox(),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: color),
                  onPressed: () async {
                    await _saveProgress();
                    if (!context.mounted) return;
                    if (widget.currentIndex < outline.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonSectionScreen(
                            lesson: widget.lesson,
                            currentIndex: widget.currentIndex + 1,
                          ),
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: TranslatedText(
                    currentIndex < outline.length - 1 ? "Next" : "Finish",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContent(Map<String, dynamic> section, Color color) {
    switch (widget.lesson["skill"]) {
      case "Listening":
        return _buildListening(section, color);
      case "Speaking":
        return _buildSpeaking(section, color);
      case "Reading":
        return _buildReading(section, color);
      case "Writing":
        return _buildWriting(section, color);
      default:
        return TranslatedText(section["description"] ?? "");
    }
  }

  // ---------------------------------------------------------------------------
  // LISTENING
  // ---------------------------------------------------------------------------
  Widget _buildListening(Map<String, dynamic> section, Color color) {
    final prompt = section["description"] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const TranslatedText(
          "Listen Carefully",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(Icons.graphic_eq, size: 60),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
                label: const TranslatedText("Play Audio"),
                style: ElevatedButton.styleFrom(backgroundColor: color),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        TranslatedText(section["description"] ?? ""),

        const SizedBox(height: 15),

        const TextField(
          decoration: InputDecoration(
            hint: TranslatedText("Type what you heard..."),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 12),

        _aiFeedbackButton(
          label: "Get AI Feedback",
          color: color,
          onPressed: () => _submitTextForFeedback(
            activityType: 'listening',
            prompt: prompt,
          ),
        ),

        if (_aiResult != null) _buildFeedbackCard(_aiResult!, color),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SPEAKING
  // ---------------------------------------------------------------------------
  Widget _buildSpeaking(Map<String, dynamic> section, Color color) {
    final prompt = section["description"] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const TranslatedText(
          "Practice Speaking",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TranslatedText(
            section["description"] ?? "Say the sentence clearly",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),

        const SizedBox(height: 30),

        /// Mic button — pulses red while recording
        GestureDetector(
          onTap: _isLoading ? null : () => _toggleRecording(prompt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording ? Colors.red : color,
              boxShadow: _isRecording
                  ? [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : [],
            ),
            padding: const EdgeInsets.all(30),
            child: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 10),

        const TranslatedText("Tap to record"),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // READING
  // ---------------------------------------------------------------------------
  Widget _buildReading(Map<String, dynamic> section, Color color) {
    final prompt = section["description"] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TranslatedText(
          "Reading Task",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: TranslatedText(section["description"] ?? ""),
          ),
        ),

        const SizedBox(height: 20),

        const TranslatedText("Answer the question:"),

        const SizedBox(height: 10),

        const TextField(
          decoration: InputDecoration(
            hint: TranslatedText("Your answer..."),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 12),

        _aiFeedbackButton(
          label: "Get AI Feedback",
          color: color,
          onPressed: () => _submitTextForFeedback(
            activityType: 'reading',
            prompt: prompt,
          ),
        ),

        if (_aiResult != null) _buildFeedbackCard(_aiResult!, color),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // WRITING
  // ---------------------------------------------------------------------------
  Widget _buildWriting(Map<String, dynamic> section, Color color) {
    final prompt = section["description"] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TranslatedText(
          "Writing Task",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        TranslatedText(section["description"] ?? ""),

        const SizedBox(height: 10),

        TextField(
          controller: _controller,
          maxLines: 6,
          decoration: InputDecoration(
            hint: TranslatedText("Write your response..."),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 12),

        _aiFeedbackButton(
          label: "Get AI Feedback",
          color: color,
          onPressed: () => _submitTextForFeedback(
            activityType: 'writing',
            prompt: prompt,
          ),
        ),

        if (_aiResult != null) _buildFeedbackCard(_aiResult!, color),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SHARED WIDGETS
  // ---------------------------------------------------------------------------

  Widget _aiFeedbackButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(_isLoading ? "Checking..." : label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> result, Color color) {
    final score = (result['score'] as num?)?.toInt() ?? 0;
    final feedback = result['feedback'] as String? ?? '';
    final nextStep = result['nextStep'] as String? ?? '';
    final isFallback = result['isFallback'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isFallback ? Icons.offline_bolt : Icons.auto_awesome,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                isFallback ? "Quick Estimate" : "AI Feedback",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$score / 100",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(feedback, style: const TextStyle(fontSize: 15)),

          if (nextStep.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.arrow_forward_ios, size: 13, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    nextStep,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
