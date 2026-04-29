import 'package:cloud_firestore/cloud_firestore.dart';

class LearningFirestoreService {
  LearningFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchLessons({
    String? skill,
    String? difficulty,
  }) {
    return _firestore.collection('lessons').snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchLessonProgress(
    String uid,
    String lessonId,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('lessonProgress')
        .doc(lessonId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserLessonProgresses(
    String uid,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('lessonProgress')
        .snapshots();
  }

  Future<void> recordLessonSectionCompletion({
    required String uid,
    required Map<String, dynamic> lesson,
    required int sectionIndex,
    required int totalSections,
  }) async {
    final lessonId = lessonDocIdFor(lesson);
    final userRef = _firestore.collection('users').doc(uid);
    final progressRef = userRef.collection('lessonProgress').doc(lessonId);
    final activityRef = userRef.collection('activityLogs').doc();
    final statsRef = userRef
        .collection('dailyStats')
        .doc(_dailyStatKey(DateTime.now()));

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final userData = userSnapshot.data() ?? <String, dynamic>{};

      final currentXp = (userData['currentXp'] as num?)?.toInt() ?? 0;
      const earnedXp = 10;
      final updatedXp = currentXp + earnedXp;
      final updatedLevel = (updatedXp ~/ 100) + 1;
      final isFinished = sectionIndex + 1 >= totalSections;

      // Compute new lesson count to evaluate achievement thresholds
      final currentLessons =
          (userData['completedLessonsCount'] as num?)?.toInt() ?? 0;
      final newLessonsCount = currentLessons + (isFinished ? 1 : 0);
      final currentStreak =
          (userData['streakDays'] as num?)?.toInt() ?? 0;

      // Build achievement updates based on thresholds
      final achievementUpdates = <String, dynamic>{};
      if (newLessonsCount >= 1) {
        achievementUpdates['achievements.firstLesson'] = true;
      }
      if (newLessonsCount >= 10) {
        achievementUpdates['achievements.tenLessons'] = true;
      }
      if (currentStreak >= 7) {
        achievementUpdates['achievements.sevenDayStreak'] = true;
      }

      transaction.set(progressRef, {
        'lessonId': lessonId,
        'lessonTitle': lesson['title'],
        'skill': lesson['skill'],
        'resumeSectionIndex': sectionIndex + 1,
        'lastSectionIndex': sectionIndex,
        'completedSections': FieldValue.increment(1),
        'totalSections': totalSections,
        'status': isFinished ? 'completed' : 'in_progress',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.update(userRef, {
        ...achievementUpdates,
        'currentXp': updatedXp,
        'currentLevel': updatedLevel,
        'completedLessonsCount': newLessonsCount,
        'totalMinutesSpent': FieldValue.increment(5),
        'lastLessonCompletedDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastSeenAt': FieldValue.serverTimestamp(),
      });

      transaction.set(activityRef, {
        'type': 'lesson_section_complete',
        'lessonId': lessonId,
        'sectionIndex': sectionIndex,
        'xpAwarded': earnedXp,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.set(statsRef, {
        'xpGained': FieldValue.increment(earnedXp),
        'activitiesCompleted': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> recordSpeakingAttempt({
    required String uid,
    required String prompt,
    required String transcript,
    required Map<String, dynamic> evaluation,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final speakingRef = userRef.collection('speakingAttempts').doc();
    final activityRef = userRef.collection('activityLogs').doc();

    final score = (evaluation['score'] as num?)?.toInt() ?? 0;
    const earnedXp = 15;

    await _firestore.runTransaction((transaction) async {
      transaction.set(speakingRef, {
        'prompt': prompt,
        'transcript': transcript,
        'score': score,
        'feedback': evaluation['feedback'],
        'correctedTranscript': evaluation['correctedTranscript'],
        'provider': evaluation['provider'],
        'model': evaluation['model'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.set(activityRef, {
        'type': 'speaking_practice_complete',
        'prompt': prompt,
        'score': score,
        'xpAwarded': earnedXp,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.update(userRef, {
        'achievements.speakingStar': true,
        'currentXp': FieldValue.increment(earnedXp),
        'totalMinutesSpent': FieldValue.increment(5),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastSeenAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> recordPracticeAttempt({
    required String uid,
    required String activityType,
    required String prompt,
    required String responseText,
    required Map<String, dynamic> evaluation,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final attemptRef = userRef.collection('practiceAttempts').doc();
    final activityRef = userRef.collection('activityLogs').doc();
    final score = (evaluation['score'] as num?)?.toInt() ?? 0;
    const earnedXp = 12;

    await _firestore.runTransaction((transaction) async {
      transaction.set(attemptRef, {
        'activityType': activityType,
        'prompt': prompt,
        'responseText': responseText,
        'score': score,
        'feedback': evaluation['feedback'],
        'correctedResponse': evaluation['correctedTranscript'],
        'provider': evaluation['provider'],
        'model': evaluation['model'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.set(activityRef, {
        'type': 'practice_attempt_complete',
        'activityType': activityType,
        'prompt': prompt,
        'score': score,
        'xpAwarded': earnedXp,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.update(userRef, {
        'currentXp': FieldValue.increment(earnedXp),
        'totalMinutesSpent': FieldValue.increment(5),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastSeenAt': FieldValue.serverTimestamp(),
      });
    });
  }

  String lessonDocIdFor(Map<String, dynamic> lesson) {
    final raw = (lesson['id'] ?? lesson['title'] ?? '').toString();
    final normalized = raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_+$'), '');
    return normalized.isEmpty ? 'lesson' : normalized;
  }

  String _dailyStatKey(DateTime dateTime) {
    return dateTime.toIso8601String().split('T').first;
  }
}
