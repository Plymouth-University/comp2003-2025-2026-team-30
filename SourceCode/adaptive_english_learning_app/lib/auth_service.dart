import 'package:firebase_auth/firebase_auth.dart';
import 'services/user_profile_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserProfileService _userProfileService = UserProfileService();

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
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;

    if (user != null) {
      await _userProfileService.createInitialProfile(
        user: user,
        email: email,
      );
    }

    return user;
  }

  
  // ======================
  // SIGN OUT
  // ======================
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
