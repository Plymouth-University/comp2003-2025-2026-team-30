import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LessonSectionScreen extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final int currentIndex;

  const LessonSectionScreen({
    super.key,
    required this.lesson,
    required this.currentIndex,
  });

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      lesson["title"],
      currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> outline =
        lesson["outline"] ?? [];

    final section = outline[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(section["title"]),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            LinearProgressIndicator(
            value: (currentIndex + 1) / outline.length,
          ),
          const SizedBox(height: 10),

          Text(
            "Section ${currentIndex + 1} of ${outline.length}",
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),

            /// Section Title
            Text(
              section["title"],
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            /// Section Description
            buildSectionContent(section),

            const Spacer(),

            /// Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                /// Previous
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
                    child: const Text("Previous"),
                  )
                else
                  const SizedBox(),

                /// Next / Finish
                ElevatedButton(
                  onPressed: () async {
                    await saveProgress();
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
                      Navigator.pop(context); // finished lesson
                    }
                  },
                  child: Text(
                    currentIndex < outline.length - 1
                        ? "Next"
                        : "Finish",
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
  Widget buildSectionContent(Map<String, dynamic> section) {
    switch (section["type"]) {

      case "Quiz":
        return buildQuiz(section);

      case "Audio":
        return buildAudio(section);

      case "Practice":
        return buildPractice(section);

      default:
        return Text(section["description"] ?? "");
    }
  }

  /// AUDIO UI (for Listening lessons)
  Widget buildAudio(Map<String, dynamic> section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section["description"] ?? ""),
        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: () {
            // later: play audio
          },
          child: const Text("Play Audio"),
        ),
      ],
    );
  }

  // Quiz UI (skill-based)
  Widget buildQuiz(Map<String, dynamic> section) {
    final skill = lesson["skill"];

    switch (skill) {

      case "Speaking":
        return Column(
          children: [
            const Text("Say this sentence aloud:"),
            const SizedBox(height: 10),
            const Text("“Tell me about yourself.”"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Record Answer"),
            ),
          ],
        );

      case "Listening":
        return Column(
          children: [
            const Text("Listen and answer the question"),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Play Audio"),
            ),
          ],
        );
      case "Reading":
        return Column(
          children: const [
            Text("Read the passage and answer the question"),
          ],
        );

      case "Writing":
        return Column(
          children: const [
            Text("Write your answer below"),
          ],
        );

      default:
        return Text(section["description"] ?? "Quiz");
    }
  }

  // Practice UI
  Widget buildPractice(Map<String, dynamic> section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section["description"] ?? ""),
        const SizedBox(height: 10),
        const TextField(
          decoration: InputDecoration(
            hintText: "Type your answer here...",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}