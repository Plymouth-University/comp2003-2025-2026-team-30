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
      await _userProfileService.createInitialProfile(user: user, email: email);
    }

    return user;
  }

  Future<void> updateEmailAddress({
    required String currentPassword,
    required String newEmail,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user was found.',
      );
    }

    await _reauthenticateWithPassword(user, currentPassword);
    await user.verifyBeforeUpdateEmail(newEmail);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user was found.',
      );
    }

    await _reauthenticateWithPassword(user, currentPassword);
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount({required String currentPassword}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user was found.',
      );
    }

    await _reauthenticateWithPassword(user, currentPassword);
    await user.delete();
  }

  // ======================
  // SIGN OUT
  // ======================
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> _reauthenticateWithPassword(
    User user,
    String currentPassword,
  ) async {
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'A password is required for this account action.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
  }
}
