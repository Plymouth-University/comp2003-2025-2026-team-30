import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  final String title;
  final String skill;
  final String difficulty;
  final String duration;
  final double progress;

  const LessonCard({
    super.key,
    required this.title,
    required this.skill,
    required this.difficulty,
    required this.duration,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [

            /// Icon Box
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.mic, size: 30),
            ),

            const SizedBox(width: 16),

            /// Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
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
                        label: Text(skill),
                        backgroundColor: Colors.orange.shade100,
                      ),

                      Chip(
                        label: Text(difficulty),
                        backgroundColor: Colors.grey.shade200,
                      ),

                      Chip(
                        label: Text(duration),
                        backgroundColor: Colors.grey.shade200,
                      ),

                    ],
                  ),
                  const SizedBox(height: 6),

                  LinearProgressIndicator(
                    value: progress,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}