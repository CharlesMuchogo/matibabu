import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
 
  Future signUp(
      {required BuildContext context,
      required String email,
      required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return 'Sign up successful';
    } on FirebaseAuth catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error !"),
              content: Text(e.toString()),
              actions: [
                MaterialButton(
                    child: Text("Okay"),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ],
            );
          });
    }
  }
}
