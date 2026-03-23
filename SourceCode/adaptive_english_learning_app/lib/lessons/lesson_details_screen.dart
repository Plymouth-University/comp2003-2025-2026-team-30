import 'package:flutter/material.dart';
import 'lesson_section_screen.dart';

class LessonDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const LessonDetailsScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final List<String> learningPoints =
        lesson["learningPoints"] ?? [];

    final List<Map<String, dynamic>> outline =
        lesson["outline"] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lesson Details"),
        leading: const BackButton(),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Top Banner - This can be an image or an icon representing the lesson type (e.g., listening, speaking)
            Container(
              height: 150,
              width: double.infinity,
              color: _getColor(lesson["skill"]),
              child: Icon(
                _getIcon(lesson["skill"]),
                size: 60,
              ),
            ),

            /// Lesson Info Card - This will show the lesson title, skill type, difficulty, duration, and a brief description
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
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
                          Chip(label: Text(lesson["skill"])),
                          Chip(label: Text(lesson["difficulty"])),
                          Chip(label: Text(lesson["duration"])),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        lesson["description"] ??
                            "No description available",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// What You'll Learn - This will list the key learning points of the lesson in a checklist format
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "What You'll Learn",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: learningPoints.map((point) {
                  return ListTile(
                    leading: const Icon(Icons.check_circle,
                        color: Colors.green),
                    title: Text(point),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            ///   Lesson Outline - This will show the structure of the lesson, such as different sections or activities, in an expandable list format
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Lesson Outline",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// DROPDOWN FOR LESSON OUTLINE - This will allow users to expand each section to see more details about the activities or content covered in that part of the lesson
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ExpansionPanelList.radio(
                elevation: 0,
                dividerColor: Colors.grey[300],
                children: outline.map((section) {
                  return ExpansionPanelRadio(
                    value: section["title"]!, // ✅ FIX

                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        leading: const Icon(Icons.menu_book),
                        title: Text(section["title"] ?? ""),
                        subtitle: Text(section["time"] ?? ""),
                      );
                    },

                    /// DESCRIPTION DROPDOWN - This will show a more detailed description of what is covered in each section of the lesson when expanded
                    body: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[100],
                      child: Text(
                        section["description"] ??
                            "No description available",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            /// Start Button - This will allow users to start the lesson, which can navigate to a new screen or trigger the lesson content to load
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonSectionScreen(
                          lesson: lesson,
                          currentIndex: 0,
                        ),
                      ),
                    );
                  },
                  child: const Text("Start Lesson"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

  Color _getColor(String skill) {
    switch (skill) {
      case "Listening":
        return Colors.blue.shade100;
      case "Speaking":
        return Colors.green.shade100;
      case "Reading":
        return Colors.orange.shade100;
      case "Writing":
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
}