import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/learning_firestore_service.dart';
import '../widgets/translated_text.dart';

class LessonSectionScreen extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final int currentIndex;

  final LearningFirestoreService _learningService = LearningFirestoreService();

  LessonSectionScreen({
    super.key,
    required this.lesson,
    required this.currentIndex,
  });

  /// Skill colors for consistent theming across sections
  static final Map<String, Color> skillColors = {
    "Listening": Colors.green,
    "Speaking": Colors.orange,
    "Reading": Colors.blue,
    "Writing": Colors.purple,
  };

  Future<void> saveProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final outline = (lesson["outline"] as List?) ?? const [];
    await _learningService.recordLessonSectionCompletion(
      uid: user.uid,
      lesson: lesson,
      sectionIndex: currentIndex,
      totalSections: outline.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> outline = lesson["outline"] ?? [];

    final section = outline[currentIndex];
    final color = skillColors[lesson["skill"]] ?? Colors.grey;

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
            /// PROGRESS
            LinearProgressIndicator(
              value: (currentIndex + 1) / outline.length,
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

            /// CONTENT (SCROLLABLE FIX)
            Expanded(
              child: SingleChildScrollView(child: buildSectionContent(section)),
            ),

            const SizedBox(height: 10),

            /// NAVIGATION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// PREVIOUS
                if (currentIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonSectionScreen(
                            lesson: lesson,
                            currentIndex: currentIndex - 1,
                          ),
                        ),
                      );
                    },
                    child: const TranslatedText("Previous"),
                  )
                else
                  const SizedBox(),

                /// NEXT / FINISH
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: color),
                  onPressed: () async {
                    await saveProgress();
                    if (!context.mounted) {
                      return;
                    }
                    if (currentIndex < outline.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonSectionScreen(
                            lesson: lesson,
                            currentIndex: currentIndex + 1,
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

  /// SECTION ROUTER
  Widget buildSectionContent(Map<String, dynamic> section) {
    final skill = lesson["skill"];

    switch (skill) {
      case "Listening":
        return buildListening(section);

      case "Speaking":
        return buildSpeaking(section);

      case "Reading":
        return buildReading(section);

      case "Writing":
        return buildWriting(section);

      default:
        return TranslatedText(section["description"] ?? "");
    }
  }

  /// LISTENING UI
  Widget buildListening(Map<String, dynamic> section) {
    final color = skillColors["Listening"]!;

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
      ],
    );
  }

  /// SPEAKING UI
  Widget buildSpeaking(Map<String, dynamic> section) {
    final color = skillColors["Speaking"]!;

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

        Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          padding: const EdgeInsets.all(30),
          child: const Icon(Icons.mic, size: 40, color: Colors.white),
        ),

        const SizedBox(height: 10),

        const TranslatedText("Tap to record"),
      ],
    );
  }

  /// READING UI
  Widget buildReading(Map<String, dynamic> section) {
    final color = skillColors["Reading"]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TranslatedText(
          "Reading Task",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        Container(
          height: 180,
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
      ],
    );
  }

  /// WRITING UI
  Widget buildWriting(Map<String, dynamic> section) {
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

        const TextField(
          maxLines: 6,
          decoration: InputDecoration(
            hint: TranslatedText("Write your response..."),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
