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
      "title": "At the Restaurant",
      "skill": "Listening",
      "difficulty": "Beginner",
      "duration": "20 min",
      "progress": 0.0,
      "description": "Master essential vocabulary for dining out",

      "learningPoints": [
        "Understand common phrases",
        "Recognize vocabulary in context",
        "Improve listening skills"
      ],

      "outline": [
        {
          "title": "Introduction",
          "time": "2 min",
          "description": "Get an overview of the lesson and what you will learn"
        },
        {
          "title": "Vocabulary",
          "time": "5 min",
          "description": "Learn essential words and phrases with examples"
        },
        {
          "title": "Quick Quiz",
          "time": "3 min",
          "description": "Test your understanding with a short quiz"
        }
      ]
    },
    {
      "title": "Job Interview Prep",
      "skill": "Speaking",
      "difficulty": "Intermediate",
      "duration": "30 min",
      "progress": 0.0,
      "description": "Prepare for common job interview questions",

      "learningPoints": [
        "Practice answering common questions",
        "Improve pronunciation and fluency",
        "Gain confidence in speaking"
      ],

      "outline": [
        {
          "title": "Common Questions",
          "time": "10 min",
          "description": "Learn how to answer frequently asked interview questions"
        },
        {
          "title": "Role Play",
          "time": "15 min",
          "description": "Practice with a simulated interview scenario"
        },
        {
          "title": "Feedback & Tips",
          "time": "5 min",
          "description": "Get feedback on your performance and tips for improvement"
        }
      ]
    },
    {
      "title": "Travel Phrases",
      "skill": "Speaking",
      "difficulty": "Beginner",
      "duration": "25 min",
      "progress": 0.0,
      "description": "Learn essential phrases for traveling abroad",

      "learningPoints": [
        "Master key travel phrases",
        "Improve pronunciation for travel situations",
        "Gain confidence in speaking while traveling"
      ],

      "outline": [
        {
          "title": "Essential Phrases",
          "time": "10 min",
          "description": "Learn important phrases for airports, hotels, and transportation"
        },
        {
          "title": "Pronunciation Practice",
          "time": "10 min",
          "description": "Practice saying the phrases with correct pronunciation"
        },
        {
          "title": "Real-Life Scenarios",
          "time": "5 min",
          "description": "Apply what you've learned in simulated travel situations"
        }
      ]
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
                  lesson: lesson,
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
            //if (selected) const Icon(Icons.check, size: 16),
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
            //if (selected) const Icon(Icons.check, size: 16),
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