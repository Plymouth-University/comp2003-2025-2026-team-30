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
  String? _proficiencyLevel;

  final _learningService = LearningFirestoreService();

  static const _difficultyOrder = ['Beginner', 'Intermediate', 'Advanced'];

  // ---------------------------------------------------------------------------
  // LESSON DATA — all lesson content lives here
  // ---------------------------------------------------------------------------
  static const List<Map<String, dynamic>> _lessons = [
    // ── LISTENING ─────────────────────────────────────────────────────────────
    {
      "title": "At the Restaurant",
      "skill": "Listening",
      "difficulty": "Beginner",
      "duration": "20 min",
      "progress": 0.0,
      "description": "Master essential vocabulary for dining out",
      "learningPoints": [
        "Understand common restaurant phrases",
        "Recognise vocabulary in context",
        "Improve listening comprehension",
      ],
      "outline": [
        {
          "title": "Dialogue",
          "type": "Listening",
          "time": "7 min",
          "description":
              "What did the customer order to drink for their friend? Write your answer below.",
          "content":
              "Read this conversation as if you are listening to it.\n\n"
              "Waiter: Good evening! Welcome to Rosewood Bistro. Do you have a reservation?\n"
              "Customer: Yes, I booked a table for two under the name Johnson.\n"
              "Waiter: Wonderful! Please follow me. Here are your menus.\n"
              "Customer: Thank you. What do you recommend tonight?\n"
              "Waiter: The grilled salmon is very popular. Can I start you off with some drinks?\n"
              "Customer: I'll have still water, and my friend will have an orange juice, please.\n"
              "Waiter: Of course! I'll be right back.",
        },
        {
          "title": "Vocabulary",
          "type": "Listening",
          "time": "8 min",
          "description":
              "Use one of the key phrases below in a brand-new sentence of your own.",
          "content":
              "Key phrases from the conversation:\n\n"
              "• 'I booked a table' – to reserve a place in advance\n"
              "• 'What do you recommend?' – asking for suggestions\n"
              "• 'Very popular' – enjoyed by many people\n"
              "• 'Start you off' – to begin with something\n"
              "• 'I'll be right back' – the speaker will return soon\n\n"
              "Re-read the dialogue and try to spot each phrase in context.",
        },
        {
          "title": "Quick Quiz",
          "type": "Listening",
          "time": "5 min",
          "description":
              "Answer in full sentences: What are the two things the customer ordered, "
              "and how did the waiter know where to seat them?",
          "content":
              "Read this follow-up exchange:\n\n"
              "Waiter: Are you ready to order?\n"
              "Customer: Yes, I would like the grilled salmon, please.\n"
              "Waiter: Excellent choice! And for your friend?\n"
              "Customer: She'll have the pasta primavera.\n"
              "Waiter: Perfect. Your food will be ready in about 20 minutes. Enjoy your evening!",
        },
      ],
    },

    {
      "title": "Business Vocabulary",
      "skill": "Listening",
      "difficulty": "Intermediate",
      "duration": "25 min",
      "progress": 0.0,
      "description": "Understand English used in workplace meetings and emails",
      "learningPoints": [
        "Recognise formal business vocabulary",
        "Follow a meeting conversation",
        "Write a short professional summary",
      ],
      "outline": [
        {
          "title": "Meeting Dialogue",
          "type": "Listening",
          "time": "10 min",
          "description":
              "What decision was made at the end of the meeting? Write it in your own words.",
          "content":
              "Read this office meeting excerpt:\n\n"
              "Manager: Right, let's get started. The agenda today covers the Q3 budget and the new client proposal.\n"
              "Team Lead: I've reviewed the figures. We're currently 8% over budget due to the additional software licences.\n"
              "Manager: Can we offset that by cutting the travel allowance this quarter?\n"
              "Team Lead: That's feasible. I'd suggest reducing it by 15%.\n"
              "Manager: Agreed. Let's action that. Now, regarding the client proposal — Sarah, can you update us?\n"
              "Sarah: Yes. We've submitted the draft and the client has requested one revision to the pricing model.\n"
              "Manager: Good. Let's reconvene Thursday to finalise it. Any other business? No? Great, we're adjourned.",
        },
        {
          "title": "Key Business Terms",
          "type": "Listening",
          "time": "10 min",
          "description":
              "Choose any two of the business terms and write a sentence using each in a professional context.",
          "content":
              "Vocabulary from the meeting:\n\n"
              "• agenda (n.) – a list of items to discuss at a meeting\n"
              "• offset (v.) – to balance one thing against another\n"
              "• feasible (adj.) – possible and practical to do\n"
              "• action (v.) – to put a decision into effect immediately\n"
              "• revision (n.) – a change made to improve something\n"
              "• reconvene (v.) – to meet again after a break\n"
              "• adjourned (adj.) – officially ended (a meeting)",
        },
        {
          "title": "Comprehension Summary",
          "type": "Listening",
          "time": "5 min",
          "description":
              "Write a 3–4 sentence summary of the meeting. Include: what was discussed, "
              "what was decided, and what happens next.",
          "content":
              "Meeting summary checklist:\n\n"
              "✓ Topic 1: Budget — what was the problem and what solution was agreed?\n"
              "✓ Topic 2: Client proposal — where is the project at, and what is the next step?\n"
              "✓ Action items: Who is responsible for what?\n\n"
              "Write your summary below in full, professional English sentences.",
        },
      ],
    },

    // ── SPEAKING ──────────────────────────────────────────────────────────────
    {
      "title": "Travel Phrases",
      "skill": "Speaking",
      "difficulty": "Beginner",
      "duration": "25 min",
      "progress": 0.0,
      "description": "Learn essential phrases for travelling abroad",
      "learningPoints": [
        "Master key travel phrases",
        "Improve pronunciation in travel situations",
        "Gain confidence speaking while travelling",
      ],
      "outline": [
        {
          "title": "Essential Phrases",
          "type": "Speaking",
          "time": "10 min",
          "description":
              "Say clearly: 'Excuse me, could you tell me how to get to the train station, please?'",
          "content":
              "Read these phrases aloud before recording:\n\n"
              "1. 'Excuse me, where is the nearest bus stop?'\n"
              "2. 'How much does this cost, please?'\n"
              "3. 'I would like a single ticket to the city centre.'\n"
              "4. 'Could you help me? I am looking for my hotel.'\n"
              "5. 'Could you speak more slowly, please? I am still learning English.'\n\n"
              "Practise each phrase at least twice before you tap the mic.",
        },
        {
          "title": "Pronunciation Practice",
          "type": "Speaking",
          "time": "10 min",
          "description":
              "Say: 'The information desk at the station is very helpful.'",
          "content":
              "Focus on these sounds:\n\n"
              "• th sound → 'the', 'this', 'there' (tongue lightly between teeth)\n"
              "• -tion ending → 'station', 'information' (sounds like 'shun')\n"
              "• Stress: ex-CU-se me (stress the second syllable)\n\n"
              "Listen back to yourself and notice if these sounds feel natural. Repeat until comfortable.",
        },
        {
          "title": "Real-Life Scenario",
          "type": "Speaking",
          "time": "5 min",
          "description":
              "You are at an airport and need help finding a taxi. "
              "Approach a staff member and ask for directions. Speak naturally and politely.",
          "content":
              "Scenario: You have just landed at an airport in an English-speaking country. "
              "You need to find a taxi to your hotel.\n\n"
              "Remember:\n"
              "• Start with 'Excuse me...'\n"
              "• Ask your question clearly\n"
              "• Thank the person at the end\n\n"
              "Tap the mic when you are ready to respond.",
        },
      ],
    },

    {
      "title": "Job Interview Prep",
      "skill": "Speaking",
      "difficulty": "Intermediate",
      "duration": "30 min",
      "progress": 0.0,
      "description": "Prepare for common job interview questions in English",
      "learningPoints": [
        "Answer common interview questions confidently",
        "Improve fluency and professional vocabulary",
        "Use the STAR method for structured answers",
      ],
      "outline": [
        {
          "title": "Tell Me About Yourself",
          "type": "Speaking",
          "time": "10 min",
          "description":
              "Answer as if in a real interview: 'Tell me about yourself and why you are applying for this role.'",
          "content":
              "Most interviews begin with 'Tell me about yourself.'\n\n"
              "Use the Present-Past-Future structure:\n"
              "• Present: 'I am currently working as a ...'\n"
              "• Past: 'Previously, I ... which helped me develop ...'\n"
              "• Future: 'I am looking for an opportunity to ...'\n\n"
              "Keep your answer to 60–90 seconds. Be specific and professional. "
              "Avoid starting every sentence with 'I' — vary your sentence structure.",
        },
        {
          "title": "STAR Role Play",
          "type": "Speaking",
          "time": "15 min",
          "description":
              "Answer this question using STAR: 'Can you describe a time when you dealt "
              "with a difficult situation at work? What did you do and what was the result?'",
          "content":
              "You are interviewing for a customer service role.\n\n"
              "Use the STAR method:\n"
              "• Situation: What was the context?\n"
              "• Task: What was your responsibility?\n"
              "• Action: What did you specifically do?\n"
              "• Result: What was the outcome?\n\n"
              "Aim for a 60–90 second response. Be specific — use real (or realistic) examples.",
        },
        {
          "title": "Closing Question",
          "type": "Speaking",
          "time": "5 min",
          "description":
              "Answer this closing question: 'Where do you see yourself in three years?'",
          "content":
              "Key tips before you record:\n\n"
              "✓ Speak at a steady, confident pace\n"
              "✓ Avoid filler words: 'um', 'uh', 'like', 'you know'\n"
              "✓ Use specific examples and numbers where possible\n"
              "✓ Show enthusiasm — interviewers notice energy\n"
              "✓ End your answer positively\n"
              "✓ Pause briefly before answering — it shows you are thinking\n\n"
              "Your goal for this final question is to sound ambitious but realistic.",
        },
      ],
    },

    // ── READING ───────────────────────────────────────────────────────────────
    {
      "title": "Reading the News",
      "skill": "Reading",
      "difficulty": "Beginner",
      "duration": "20 min",
      "progress": 0.0,
      "description":
          "Practice reading a short news article and answer comprehension questions",
      "learningPoints": [
        "Read and understand simple news texts",
        "Identify key information in a passage",
        "Expand vocabulary through context",
      ],
      "outline": [
        {
          "title": "Read the Story",
          "type": "Reading",
          "time": "8 min",
          "description":
              "What is this article about? Write one or two sentences summarising the main topic.",
          "content":
              "LOCAL LIBRARY OPENS FREE ENGLISH CLASSES\n\n"
              "The Central City Library has announced a new programme of free English classes for adults. "
              "The classes will begin next Monday and run every Tuesday and Thursday evening from 6:00pm to 8:00pm.\n\n"
              "'We want to help everyone in our community feel confident speaking English,' said library director "
              "Sarah Osei. 'Whether you are new to the country or simply want to improve your skills, these classes are open to all.'\n\n"
              "The classes are free to attend but students must register in advance. "
              "There are 25 places available. Interested learners can sign up at the library reception or through the library's website.",
        },
        {
          "title": "Vocabulary in Context",
          "type": "Reading",
          "time": "7 min",
          "description":
              "Choose any one of the words below and write a new sentence of your own using it correctly.",
          "content":
              "Key words from the article:\n\n"
              "• announced (verb) – made something known to the public\n"
              "  → 'The school announced the exam results.'\n\n"
              "• programme (noun) – a planned series of activities\n"
              "  → 'She joined a fitness programme at the gym.'\n\n"
              "• register (verb) – to officially sign up for something\n"
              "  → 'You must register before the course starts.'\n\n"
              "• available (adjective) – ready to use or obtain\n"
              "  → 'Are there any seats available on the train?'\n\n"
              "• reception (noun) – the front desk or entrance area of a building",
        },
        {
          "title": "Comprehension Check",
          "type": "Reading",
          "time": "5 min",
          "description":
              "Answer in full sentences: How many places are available, "
              "and what are the TWO ways someone can sign up for the classes?",
          "content":
              "Key facts from the article:\n"
              "• Classes start: Next Monday\n"
              "• Schedule: Tuesdays & Thursdays, 6:00pm–8:00pm\n"
              "• Cost: Free\n"
              "• Requirement: Must register in advance\n"
              "• Spaces: 25\n"
              "• How to sign up: (1) Library reception  (2) Library website\n\n"
              "Re-read the article if needed, then write your answer below in complete sentences.",
        },
      ],
    },

    // ── WRITING ───────────────────────────────────────────────────────────────
    {
      "title": "Write About Your Day",
      "skill": "Writing",
      "difficulty": "Beginner",
      "duration": "25 min",
      "progress": 0.0,
      "description":
          "Practice writing simple sentences about everyday activities",
      "learningPoints": [
        "Write simple sentences using past tense",
        "Describe everyday activities clearly",
        "Use time expressions correctly",
      ],
      "outline": [
        {
          "title": "Warm Up",
          "type": "Writing",
          "time": "5 min",
          "description":
              "Complete this sentence in as many ways as you can: 'Every morning I...' — write at least three endings.",
          "content":
              "Useful words and phrases for writing about routines:\n\n"
              "Time expressions:\n"
              "First, ... / Then, ... / After that, ... / Finally, ...\n"
              "In the morning / At lunchtime / In the evening\n"
              "Every day / Usually / Always / Sometimes\n\n"
              "Example:\n"
              "'Every morning I wake up at 7am and make a cup of tea. "
              "Then I take a shower and get ready for the day. "
              "After that, I eat breakfast before leaving the house.'",
        },
        {
          "title": "Write Your Day",
          "type": "Writing",
          "time": "15 min",
          "description":
              "Write a short paragraph (4–6 sentences) describing what you did yesterday, "
              "from morning to evening. Use past tense verbs and at least one time expression.",
          "content":
              "Structure to follow:\n"
              "1. Morning – What did you do after waking up?\n"
              "2. Afternoon – Where did you go or what did you work on?\n"
              "3. Evening – How did you spend your evening?\n\n"
              "Past tense reminder:\n"
              "go → went  |  eat → ate  |  see → saw\n"
              "make → made  |  take → took  |  have → had\n"
              "wake → woke  |  get → got  |  feel → felt\n\n"
              "Target: at least 4 complete sentences.",
        },
        {
          "title": "Edit and Improve",
          "type": "Writing",
          "time": "5 min",
          "description":
              "Read your paragraph again, fix any mistakes, and paste the improved version here.",
          "content":
              "Self-editing checklist:\n\n"
              "✓ Every sentence starts with a CAPITAL LETTER\n"
              "✓ Every sentence ends with a FULL STOP (.)\n"
              "✓ Past tense verbs are used correctly (went, ate, saw…)\n"
              "✓ At least one time expression is included\n"
              "✓ The paragraph has 4 or more sentences\n"
              "✓ The meaning is clear when read aloud\n\n"
              "Read your writing out loud slowly. If something sounds wrong, it probably needs fixing.",
        },
      ],
    },
  ];

  final Map<String, Map<String, dynamic>> skillThemes = {
    "Listening": {"color": Colors.green, "icon": Icons.headphones},
    "Speaking": {"color": Colors.orange, "icon": Icons.mic},
    "Reading": {"color": Colors.blue, "icon": Icons.menu_book},
    "Writing": {"color": Colors.purple, "icon": Icons.edit},
  };

  @override
  void initState() {
    super.initState();
    _loadProficiency();
  }

  Future<void> _loadProficiency() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (mounted) {
      setState(
        () => _proficiencyLevel = doc.data()?['proficiencyLevel'] as String?,
      );
    }
  }

  bool _isLocked(String lessonDifficulty) {
    if (_proficiencyLevel == null) return false;
    final userIdx = _difficultyOrder.indexOf(_proficiencyLevel!);
    final lessonIdx = _difficultyOrder.indexOf(lessonDifficulty);
    if (userIdx < 0) return false;
    return lessonIdx > userIdx;
  }

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
          /// Skill filter chips
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

          /// Lesson list — live progress from Firestore, locked by proficiency
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
                              (data['completedSections'] as num?)?.toDouble() ??
                              0;
                          final total =
                              (data['totalSections'] as num?)?.toDouble() ?? 1;
                          progressMap[doc.id] =
                              (completed / total).clamp(0.0, 1.0);
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
    final filtered = _lessons.where((lesson) {
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
      itemBuilder: (context, index) {
        final lesson = filtered[index];
        return LessonCard(
          lesson: lesson,
          isLocked: _isLocked(lesson["difficulty"] as String? ?? ''),
        );
      },
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
                theme?["icon"] as IconData? ?? Icons.school,
                size: 18,
                color: selected ? Colors.white : theme?["color"] as Color?,
              )
            : null,
        label: TranslatedText(label),
        selected: selected,
        selectedColor: theme?["color"] as Color? ?? Colors.grey,
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
        onSelected: (_) => setState(() => selectedSkill = label),
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
        onSelected: (_) => setState(() => selectedDifficulty = label),
      ),
    );
  }
}
