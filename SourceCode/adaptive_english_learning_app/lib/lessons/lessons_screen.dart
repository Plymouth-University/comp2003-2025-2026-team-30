import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/learning_firestore_service.dart';
import 'lesson_card.dart';
import '../widgets/translated_text.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  String selectedSkill = "All";
  String selectedDifficulty = "Beginner";
  final _learningService = LearningFirestoreService();

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
        "Improve listening skills",
      ],
      "outline": [
        {
          "title": "Introduction",
          "type": "Audio",
          "time": "2 min",
          "description":
              "Get an overview of the lesson and what you will learn",
        },
        {
          "title": "Vocabulary",
          "type": "Audio",
          "time": "5 min",
          "description": "Learn essential words and phrases with examples",
        },
        {
          "title": "Quick Quiz",
          "type": "Quiz",
          "time": "3 min",
          "description": "Test your understanding with a short quiz",
        },
      ],
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
        "Gain confidence in speaking",
      ],
      "outline": [
        {
          "title": "Common Questions",
          "type": "Audio",
          "time": "10 min",
          "description":
              "Learn how to answer frequently asked interview questions",
        },
        {
          "title": "Role Play",
          "type": "Audio",
          "time": "15 min",
          "description": "Practice with a simulated interview scenario",
        },
        {
          "title": "Feedback & Tips",
          "type": "Audio",
          "time": "5 min",
          "description":
              "Get feedback on your performance and tips for improvement",
        },
      ],
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
        "Gain confidence in speaking while traveling",
      ],
      "outline": [
        {
          "title": "Essential Phrases",
          "type": "Audio",
          "time": "10 min",
          "description":
              "Learn important phrases for airports, hotels, and transportation",
        },
        {
          "title": "Pronunciation Practice",
          "type": "Audio",
          "time": "10 min",
          "description":
              "Practice saying the phrases with correct pronunciation",
        },
        {
          "title": "Real-Life Scenarios",
          "type": "Audio",
          "time": "5 min",
          "description":
              "Apply what you've learned in simulated travel situations",
        },
      ],
    },
  ];

  /// FILTER LOGIC - This will return a new list of lessons based on the selected filters
  List<Map<String, dynamic>> get filteredLessons {
    return lessons.where((lesson) {
      final matchesSkill =
          selectedSkill == "All" || lesson["skill"] == selectedSkill;

      final matchesDifficulty = lesson["difficulty"] == selectedDifficulty;

      return matchesSkill && matchesDifficulty;
    }).toList();
  }

  final Map<String, Map<String, dynamic>> skillThemes = {
    "Listening": {"color": Colors.green, "icon": Icons.headphones},
    "Speaking": {"color": Colors.orange, "icon": Icons.mic},
    "Reading": {"color": Colors.blue, "icon": Icons.menu_book},
    "Writing": {"color": Colors.purple, "icon": Icons.edit},
  };

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const TranslatedText("Lessons"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.search),
          ),
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

          /// Difficulty filter chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              difficultyChip("Beginner"),
              difficultyChip("Intermediate"),
              difficultyChip("Advanced"),
            ],
          ),

          const SizedBox(height: 10),

          /// Lesson list — wired to live Firestore progress
          Expanded(
            child: user == null
                ? _buildList({})
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _learningService.watchUserLessonProgresses(user.uid),
                    builder: (context, snapshot) {
                      final progressMap = <String, double>{};
                      if (snapshot.hasData) {
                        for (final doc in snapshot.data!.docs) {
                          final data = doc.data();
                          final completed =
                              (data['completedSections'] as num?)?.toInt() ?? 0;
                          final total =
                              (data['totalSections'] as num?)?.toInt() ?? 1;
                          progressMap[doc.id] = completed / total;
                        }
                      }
                      return _buildList(progressMap);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(Map<String, double> progressMap) {
    final filtered = lessons.where((lesson) {
      final matchesSkill =
          selectedSkill == "All" || lesson["skill"] == selectedSkill;
      final matchesDifficulty = lesson["difficulty"] == selectedDifficulty;
      return matchesSkill && matchesDifficulty;
    }).map((lesson) {
      final lessonId = _learningService.lessonDocIdFor(lesson);
      return {...lesson, 'progress': progressMap[lessonId] ?? 0.0};
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No lessons available for this filter."));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) => LessonCard(lesson: filtered[index]),
    );
  }

  Widget skillChip(String label) {
    final selected = selectedSkill == label;
    final theme = skillThemes[label];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        avatar: label != "All"
            ? Icon(
                theme?["icon"] ?? Icons.school,
                size: 18,
                color: selected ? Colors.white : theme?["color"],
              )
            : null,
        label: TranslatedText(label),
        selected: selected,
        selectedColor: theme?["color"] ?? Colors.grey,
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
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
        label: TranslatedText(label),
        selected: selected,
        selectedColor: Colors.black,
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
        onSelected: (_) {
          setState(() {
            selectedDifficulty = label;
          });
        },
      ),
    );
  }
}
