import 'package:flutter/material.dart';
import 'lesson_card.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  String selectedSkill = "All";
  String selectedDifficulty = "Beginner";

  final List<Map<String, dynamic>> lessons = [
    {
      "title": "Greetings & Introductions",
      "skill": "Speaking",
      "difficulty": "Beginner",
      "duration": "15 min",
      "progress": 0.6
    },
    {
      "title": "At the Restaurant",
      "skill": "Listening",
      "difficulty": "Beginner",
      "duration": "20 min",
      "progress": 0.0
    },
    {
      "title": "Shopping Conversations",
      "skill": "Speaking",
      "difficulty": "Intermediate",
      "duration": "25 min",
      "progress": 0.0
    },
  ];

  /// FILTER LOGIC - This will return a new list of lessons based on the selected filters
  List<Map<String, dynamic>> get filteredLessons {
    return lessons.where((lesson) {
      final matchesSkill =
          selectedSkill == "All" || lesson["skill"] == selectedSkill;

      final matchesDifficulty =
          lesson["difficulty"] == selectedDifficulty;

      return matchesSkill && matchesDifficulty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lessons"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.search),
          )
        ],
      ),

      body: Column(
        children: [

          /// Skill Filter - This will allow users to filter lessons by skill type (Listening, Speaking, etc.)
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                skillChip("All"),
                skillChip("Listening"),
                skillChip("Speaking"),
                skillChip("Reading"),
                skillChip("Writing"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// Difficulty Filter - This will allow users to filter lessons by difficulty level (Beginner, Intermediate, Advanced)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              difficultyChip("Beginner"),
              difficultyChip("Intermediate"),
              difficultyChip("Advanced"),
            ],
          ),

          const SizedBox(height: 10),

          /// USE FILTERED LIST HERE - This will display the lessons that match the selected filters
          Expanded(
            child: ListView.builder(
              itemCount: filteredLessons.length,
              itemBuilder: (context, index) {
                final lesson = filteredLessons[index];

                return LessonCard(
                  title: lesson["title"],
                  skill: lesson["skill"],
                  difficulty: lesson["difficulty"],
                  duration: lesson["duration"],
                  progress: lesson["progress"],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget skillChip(String label) {
    final selected = selectedSkill == label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) const Icon(Icons.check, size: 16),
            if (selected) const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: (_) {
          setState(() {
            selectedSkill = label;
          });
        },
      ),
    );
  }

  Widget difficultyChip(String label) {
    final selected = selectedDifficulty == label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) const Icon(Icons.check, size: 16),
            if (selected) const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: (_) {
          setState(() {
            selectedDifficulty = label;
          });
        },
      ),
    );
  }
}