import 'package:flutter/material.dart';

class LessonDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const LessonDetailsScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final List<String> learningPoints =
        lesson["learningPoints"] ?? [];

    final List<Map<String, String>> outline =
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

            /// Top Banner - This will show an image or icon related to the lesson topic
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.blue.shade100,
              child: const Icon(Icons.headphones, size: 60),
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

            /// What You'll Learn - This will show a list of key learning points that the user can expect to gain from the lesson
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
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(point),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            /// Lesson Outline - This will show the different sections of the lesson (e.g., Introduction, Practice, Quiz)
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

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: outline.map((item) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.menu_book),
                      title: Text(item["title"] ?? ""),
                      subtitle: Text(item["time"] ?? ""),
                      trailing: const Icon(Icons.expand_more),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            /// Start Button - This will eventually trigger the lesson content to start
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Start lesson logic
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
}