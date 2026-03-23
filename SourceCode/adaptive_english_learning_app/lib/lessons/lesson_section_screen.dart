import 'package:flutter/material.dart';

class LessonSectionScreen extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final int currentIndex;

  const LessonSectionScreen({
    super.key,
    required this.lesson,
    required this.currentIndex,
  });

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

            /// Section Title
            Text(
              section["title"],
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            /// Section Description
            Text(
              section["description"] ??
                  "No content available",
              style: const TextStyle(fontSize: 16),
            ),

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
                  onPressed: () {
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
}