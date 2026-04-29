import 'package:flutter/material.dart';
import 'lesson_details_screen.dart';
import '../widgets/translated_text.dart';

class LessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final bool isLocked;

  const LessonCard({super.key, required this.lesson, this.isLocked = false});

  static final Map<String, Map<String, dynamic>> skillThemes = {
    "Listening": {"color": Colors.green, "icon": Icons.headphones},
    "Speaking": {"color": Colors.orange, "icon": Icons.mic},
    "Reading": {"color": Colors.blue, "icon": Icons.menu_book},
    "Writing": {"color": Colors.purple, "icon": Icons.edit},
  };

  String get _lockMessage {
    final difficulty = lesson['difficulty'] as String? ?? '';
    if (difficulty == 'Intermediate') {
      return 'Complete Beginner lessons to unlock Intermediate content.';
    }
    if (difficulty == 'Advanced') {
      return 'Complete Intermediate lessons to unlock Advanced content.';
    }
    return 'This lesson is locked. Complete earlier lessons first.';
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        skillThemes[lesson["skill"]] ??
        {"color": Colors.grey, "icon": Icons.school};
    final color = theme["color"] as Color;

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_lockMessage),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LessonDetailsScreen(lesson: lesson),
          ),
        );
      },
      child: Stack(
        children: [
          /// The card — dimmed when locked
          Opacity(
            opacity: isLocked ? 0.55 : 1.0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  /// Skill icon box
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      theme["icon"] as IconData,
                      size: 30,
                      color: color,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TranslatedText(
                          lesson["title"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            TranslatedText(
                              lesson["difficulty"],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 10),
                            TranslatedText(
                              lesson["duration"],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

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
                  ),
                ],
              ),
            ),
          ),

          /// Lock badge — top right corner
          if (isLocked)
            Positioned(
              top: 18,
              right: 28,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
