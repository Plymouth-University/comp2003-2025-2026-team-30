import 'package:flutter/material.dart';
import 'lesson_details_screen.dart';

class LessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const LessonCard({
    super.key,
    required this.lesson,
  });

  static final Map<String, Map<String, dynamic>> skillThemes = {
    "Listening": {
      "color": Colors.green,
      "icon": Icons.headphones,
    },
    "Speaking": {
      "color": Colors.orange,
      "icon": Icons.mic,
    },
    "Reading": {
      "color": Colors.blue,
      "icon": Icons.menu_book,
    },
    "Writing": {
      "color": Colors.purple,
      "icon": Icons.edit,
    },
  };

  @override
  Widget build(BuildContext context) {
    final theme = skillThemes[lesson["skill"]] ??
        {"color": Colors.grey, "icon": Icons.school};

    final color = theme["color"];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LessonDetailsScreen(lesson: lesson),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [

            /// ICON BOX (now themed)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                theme["icon"],
                size: 30,
                color: color,
              ),
            ),

            const SizedBox(width: 16),

            /// TEXT CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TITLE
                  Text(
                    lesson["title"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// META INFO (cleaner than chips)
                  Row(
                    children: [
                      Text(
                        lesson["difficulty"],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        lesson["duration"],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// PROGRESS BAR
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: lesson["progress"] ?? 0.0,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}