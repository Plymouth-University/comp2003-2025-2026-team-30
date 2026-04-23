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
        'currentXp': updatedXp,
        'currentLevel': updatedLevel,
        'completedLessonsCount': FieldValue.increment(isFinished ? 1 : 0),
        'totalMinutesSpent': FieldValue.increment(5),
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
