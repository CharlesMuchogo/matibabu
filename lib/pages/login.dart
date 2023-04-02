// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/pages/resetpassword.dart';
import 'package:matibabu/pages/signup.dart';

class login extends StatefulWidget {
  @override
  State<login> createState() => _loginState();
}

final Future<FirebaseApp> initialize = Firebase.initializeApp();

class _loginState extends State<login> {
  int _selectedPageIndex = 0;
  TextEditingController emailcontroler = TextEditingController();
  TextEditingController passwordcontroler = TextEditingController();
  GlobalKey formkey = GlobalKey();
  bool _isloading = false;
  int navigateToSignup() {
    setState(() {
      _selectedPageIndex = 1;
    });
    return _selectedPageIndex;
  }

  @override
  Widget build(BuildContext context) {
    double heightOfDevice = MediaQuery.of(context).size.height;

    final FirebaseAuth _auth = FirebaseAuth.instance;

    void navigate() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Signup()),
      );
    }

    Future<void> login() async {
      setState(() {
        _isloading = true;
      });

      try {
        await _auth.signInWithEmailAndPassword(
            email: emailcontroler.text.toLowerCase().trim(),
            password: passwordcontroler.text.trim());
        setState(() {
          _isloading = false;
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isloading = false;
        });
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error!"),
              content: Text(
                e.message.toString(),
              ),
              actions: [
                MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Okay"))
              ],
            );
          },
        );
      }
    }

    return Scaffold(
        body: ListView(
      children: [
        Container(
          height: heightOfDevice * 0.25,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              logo(
                "Matibabu",
                32,
                Colors.teal,
              ),
              logo("Health Is Wealth", 17, Colors.black)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Form(
            key: formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                textfields(emailcontroler, "Enter your Email Address"),
                const SizedBox(
                  height: 20,
                ),
                textfields(passwordcontroler, "Enter your password"),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(fontSize: 18, color: Colors.teal),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ResetPassword()),
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
                    child: _isloading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text("Login"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Dont have an account? ",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    InkWell(
                      onTap: navigate,
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.teal,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    ));
  }

  Widget textfields(
    TextEditingController textfieldcontroler,
    String placeholder,
  ) {
    if (placeholder == "Enter your password") {
      return TextFormField(
        obscureText: true,
        controller: textfieldcontroler,
        decoration: InputDecoration(
          labelText: placeholder,
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
      );
    } else {
      return TextFormField(
        controller: textfieldcontroler,
        decoration: InputDecoration(
          labelText: placeholder,
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
      );
    }
  }

  Widget logo(String logocomponent, double fontsize, Color textcolor) {
    return Text(
      logocomponent,
      style:
          TextStyle(color: textcolor, fontSize: fontsize, letterSpacing: 1.5),
    );
  }
}
