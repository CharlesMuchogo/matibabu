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
              title: Text(
                "Success",
                style: TextStyle(color: Colors.green),
              ),
              content: Text(
                "Password reset email has been sent. Check your mail. If you don't see the mail in your inbox, check your spam folder",
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Okay", style: TextStyle(color: Colors.blue)),
                )
              ],
            );
          });
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Failed!", style: TextStyle(color: Colors.red)),
              content: Text(
                e.message.toString(),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Okay", style: TextStyle(color: Colors.blue)),
                )
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reset password"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Enter your email to reset password",
                style: TextStyle(fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.black45,
                        width: 1.5,
                      ),
                    ),
                  ),
                  controller: resetPassword,
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    _resetPassword(context);
                  },
                  child: Text("Reset Password"))
            ],
          ),
        ),
      ),
    );
  }
}
