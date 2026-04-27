import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  UserProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUserProfile(String uid) {
    return _users.doc(uid).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchUserProfile(String uid) {
    return _users.doc(uid).get();
  }

  Future<void> ensureUserProfile(User user) async {
    final ref = _users.doc(user.uid);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'email': user.email ?? '',
        'displayName': user.displayName ?? 'Learner',
        'photoUrl': user.photoURL,
        'onboardingCompleted': false,
        'nativeLanguage': null,
        'targetLanguage': 'English',
        'proficiencyLevel': null,
        'learningGoal': null,
        'learningStyle': null,
        'currentXp': 0,
        'currentLevel': 1,
        'streakDays': 0,
        'completedLessonsCount': 0,
        'totalMinutesSpent': 0,
        'lastLessonCompletedDate': null,
        'achievements': {
          'firstLesson': false,
          'sevenDayStreak': false,
          'tenLessons': false,
          'speakingStar': false,
        },
        'lastSeenAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.set({
        'email': user.email ?? '',
        'displayName': user.displayName ?? 'Learner',
        'photoUrl': user.photoURL,
        'lastSeenAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> saveOnboardingProfile({
  required String uid,
  required Map<String, dynamic> answers,
}) async {
  await _users.doc(uid).set({
    ...answers,
    'onboardingCompleted': true,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

Future<void> logPlacementAttempt({
  required String uid,
  required Map<String, dynamic> payload,
}) async {
  await _users.doc(uid).collection('placementAttempts').add({
    ...payload,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

  Future<void> recordLessonCompleted({
    required String uid,
    int minutesSpent = 1,
  }) async {
    final userRef = _users.doc(uid);

    final snap = await userRef.get();
    final data = snap.data() ?? <String, dynamic>{};

    final currentLessons =
        (data['completedLessonsCount'] as num?)?.toInt() ?? 0;
    final newLessonCount = currentLessons + 1;

    final currentStreak = (data['streakDays'] as num?)?.toInt() ?? 0;
    final lastCompleted = data['lastLessonCompletedDate'];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak = currentStreak;

    if (lastCompleted == null) {
      newStreak = 1;
    } else {
      final lastDateTime = (lastCompleted as Timestamp).toDate();
      final lastDate = DateTime(
        lastDateTime.year,
        lastDateTime.month,
        lastDateTime.day,
      );

      final difference = today.difference(lastDate).inDays;

      if (difference == 0) {
        newStreak = currentStreak;
      } else if (difference == 1) {
        newStreak = currentStreak + 1;
      } else {
        newStreak = 1;
      }
    }

    await userRef.update({
      'completedLessonsCount': FieldValue.increment(1),
      'totalMinutesSpent': FieldValue.increment(minutesSpent),
      'streakDays': newStreak,
      'lastLessonCompletedDate': FieldValue.serverTimestamp(),
      'achievements.firstLesson': true,
      if (newLessonCount >= 10) 'achievements.tenLessons': true,
      if (newStreak >= 7) 'achievements.sevenDayStreak': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}