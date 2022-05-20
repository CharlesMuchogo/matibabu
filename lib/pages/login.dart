// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/pages/signup.dart';

class login extends StatefulWidget {
  @override
  State<login> createState() => _loginState();
}

final Future<FirebaseApp> initialize = Firebase.initializeApp();

class _loginState extends State<login> {
  TextEditingController emailcontroler = TextEditingController();
  TextEditingController passwordcontroler = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void login() {
    try {
      _auth.signInWithEmailAndPassword(
          email: emailcontroler.text.toLowerCase().trim(),
          password: passwordcontroler.text.trim());
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double heightOfDevice = MediaQuery.of(context).size.height;

    String errors = '';
    return Scaffold(
      body: FutureBuilder<Object>(
          future: null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Material(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasError) {
              return Material(
                child: Center(
                  child: Text("Error Occured. Reaload the application"),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: heightOfDevice * 0.25,
                  width: double.infinity,
                  child: Center(
                    child: ListTile(
                      title: Text(
                        "Matibabu",
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                      subtitle: Text(
                        "Health is Wealth",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      textfields(
                          emailcontroler, "Enter your Email Address", errors),
                      const SizedBox(
                        height: 20,
                      ),
                      textfields(
                          passwordcontroler, "Enter your password", errors),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                              fontSize: 18,
                              color: Color.fromRGBO(43, 147, 128, 20)),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Signup()),
                          );
                        },
                      ),
                      SizedBox(
                        height: 23,
                      ),
                      SizedBox(
                        height: 42,
                        width: 196,
                        child: ElevatedButton(
                          onPressed: login,
                          child: Text("Login"),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      SizedBox(
                        height: 42,
                        width: 196,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Signup()),
                            );
                          },
                          child: Text("Sign Up"),
                          style: ElevatedButton.styleFrom(
                              primary: Color.fromRGBO(43, 147, 128, 20)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}

Widget textfields(
  TextEditingController textfieldcontroler,
  String placeholder,
  String error,
) {
  if (placeholder == "Enter your password") {
    return TextFormField(
      obscureText: true,
      controller: textfieldcontroler,
      decoration: InputDecoration(
        labelText: placeholder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Color.fromRGBO(43, 147, 128, 20)),
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
    );
  } else {
    return TextFormField(
      controller: textfieldcontroler,
      decoration: InputDecoration(
        labelText: placeholder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Color.fromRGBO(43, 147, 128, 20)),
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
    );
  }
}
