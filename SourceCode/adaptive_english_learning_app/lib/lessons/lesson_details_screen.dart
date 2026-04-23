import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/learning_firestore_service.dart';
import 'lesson_section_screen.dart';

class LessonDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> lesson;

  final LearningFirestoreService _learningService = LearningFirestoreService();

  LessonDetailsScreen({super.key, required this.lesson});

  Future<int> loadProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 0;
    }

    final snapshot = await _learningService
        .watchLessonProgress(user.uid, _learningService.lessonDocIdFor(lesson))
        .first;

    final data = snapshot.data();
    final resumeIndex = (data?['resumeSectionIndex'] as num?)?.toInt() ?? 0;
    final outline = (lesson['outline'] as List?) ?? const [];

    if (resumeIndex >= outline.length) {
      return 0;
    }

    return resumeIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> learningPoints = lesson["learningPoints"] ?? [];

    final List<Map<String, dynamic>> outline = lesson["outline"] ?? [];

    final color = _getColor(lesson["skill"]);

    return Scaffold(
      appBar: AppBar(title: const Text("Lesson Details"), elevation: 0),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP BANNER - This will show a large icon and the skill type (e.g., Listening, Speaking) with a background color representing the skill
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIcon(lesson["skill"]),
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lesson["skill"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// LESSON INFO - This will show the lesson title, description, and key info (difficulty, duration) in a card format
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson["title"],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        children: [
                          _buildInfoChip(lesson["skill"]),
                          _buildInfoChip(lesson["difficulty"]),
                          _buildInfoChip(lesson["duration"]),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        lesson["description"] ?? "No description available",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// WHAT YOU’LL LEARN - This will show a list of key learning points or outcomes for the lesson, giving users a clear idea of what they will achieve by completing it
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "What You'll Learn",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: learningPoints.map((point) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(child: Text(point)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            /// LESSON OUTLINE - This will show an expandable list of the lesson sections or modules, allowing users to see the structure of the lesson and what each section will cover before they start
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Lesson Outline",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ExpansionPanelList.radio(
                elevation: 0,
                children: outline.map((section) {
                  return ExpansionPanelRadio(
                    value: section["title"],

                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        leading: Icon(_getIcon(lesson["skill"]), color: color),
                        title: Text(section["title"] ?? ""),
                        subtitle: Text(section["time"] ?? ""),
                      );
                    },

                    body: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        section["description"] ?? "No description available",
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),

            /// START BUTTON - This will allow users to start the lesson, taking them to the first section of the lesson outline. It will also save their progress so they can resume later if needed
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final index = await loadProgress();
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonSectionScreen(
                          lesson: lesson,
                          currentIndex: index,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Start Lesson",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// INFO CHIP - This is a reusable widget for displaying key information about the lesson (e.g., skill type, difficulty, duration) in a compact and visually appealing way
  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  /// ICON MAPPING - This is a helper function to return an appropriate icon based on the skill type of the lesson, adding a visual element that helps users quickly identify the lesson type
  IconData _getIcon(String skill) {
    switch (skill) {
      case "Listening":
        return Icons.headphones;
      case "Speaking":
        return Icons.mic;
      case "Reading":
        return Icons.menu_book;
      case "Writing":
        return Icons.edit;
      default:
        return Icons.school;
    }
  }

  /// COLOR MAPPING - This is a helper function to return a specific color based on the skill type of the lesson, which is used in the top banner and icons to create a cohesive visual theme for each lesson type
  Color _getColor(String skill) {
    switch (skill) {
      case "Listening":
        return Colors.green;
      case "Speaking":
        return Colors.orange;
      case "Reading":
        return Colors.blue;
      case "Writing":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
