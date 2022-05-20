import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _auth;
  AuthenticationService(this._auth);

  Stream<User?> get authstateChanges => _auth.authStateChanges();
  User? get userid => _auth.currentUser;

  Future<String> signIn(
      {required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return 'Sign in successful';
    } on FirebaseAuth catch (e) {
      return e.toString();
    }
  }

  Future<String> signUp(
      {required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return 'Sign up successful';
    } on FirebaseAuth catch (e) {
      return e.toString();
    }
  }
}
