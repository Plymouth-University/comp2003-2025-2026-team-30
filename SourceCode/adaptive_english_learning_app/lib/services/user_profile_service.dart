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
  
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchUserProfile(
    String uid,
  ) {
    return _users.doc(uid).get();
  }

  Future<void> createInitialProfile({
    required User user,
    required String email,
  }) {
    return _users.doc(user.uid).set({
      'email': email,
      'displayName': user.displayName,
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
      'lastSeenAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> ensureUserProfile(User user) {
    return _users.doc(user.uid).set({
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'lastSeenAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveOnboardingProfile({
    required String uid,
    required Map<String, dynamic> answers,
  }) {
    return _users.doc(uid).set({
      ...answers,
      'onboardingCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
      'lastSeenAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> logPlacementAttempt({
    required String uid,
    required Map<String, dynamic> payload,
  }) {
    return _users.doc(uid).collection('placementAttempts').add({
      ...payload,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}