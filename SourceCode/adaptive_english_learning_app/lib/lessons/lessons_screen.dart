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

          /// Skill Filter
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

          /// Difficulty Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              difficultyChip("Beginner"),
              difficultyChip("Intermediate"),
              difficultyChip("Advanced"),
            ],
          ),

          const SizedBox(height: 10),

          /// Lesson List
          Expanded(
            child: ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];

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
        label: Text(label),
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
        label: Text(label),
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