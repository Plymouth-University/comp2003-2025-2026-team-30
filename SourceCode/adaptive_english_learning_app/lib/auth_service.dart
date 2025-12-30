import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ======================
  // LOGIN
  // ======================
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // ======================
  // SIGN UP WITH ROLE
  // ======================
  Future<User?> signUp({
    required String email,
    required String password,
    required String role,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'role': role,
        'createdAt': Timestamp.now(),
      });
    }

    return user;
  }

  // ======================
  // GET USER ROLE
  // ======================
  Future<String?> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['role'];
  }

  // ======================
  // SIGN OUT
  // ======================
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
