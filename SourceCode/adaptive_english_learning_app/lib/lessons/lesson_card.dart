import 'package:flutter/material.dart';
import 'lesson_details_screen.dart';

class LessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const LessonCard({
    super.key,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LessonDetailsScreen(lesson: lesson),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [

              /// Icon Box (dynamic later if needed) - This will show an icon representing the lesson type (e.g., listening, speaking)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(lesson["skill"]),
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              /// Text Content - This will show the lesson title, skill type, difficulty, duration, and a progress bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      lesson["title"],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [

                        Chip(
                          label: Text(lesson["skill"]),
                          backgroundColor: Colors.orange.shade100,
                        ),

                        Chip(
                          label: Text(lesson["difficulty"]),
                          backgroundColor: Colors.grey.shade200,
                        ),

                        Chip(
                          label: Text(lesson["duration"]),
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    LinearProgressIndicator(
                      value: lesson["progress"] ?? 0.0,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Dynamic icon based on lesson type - This is just a simple example, you can expand it with more types and icons as needed
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
}