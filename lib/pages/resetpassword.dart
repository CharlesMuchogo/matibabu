import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatelessWidget {
  TextEditingController resetPassword = TextEditingController();
  Future _resetPassword(BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: resetPassword.text.trim());
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                "Password reset email has been sent. Check your mail",
              ),
            );
          });
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                e.message.toString(),
              ),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: resetPassword,
            ),
            Padding(padding: EdgeInsets.all(10)),
            ElevatedButton(
                onPressed: () {
                  _resetPassword(context);
                },
                child: Text("Reset Password"))
          ],
        ),
      ),
    );
  }
}
