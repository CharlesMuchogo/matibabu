// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:matibabu/GlobalComponents/authenticationservice.dart';

import 'package:matibabu/GlobalComponents/restapi.dart';
import 'package:matibabu/pages/login.dart';
import 'package:provider/provider.dart';

import '../GlobalComponents/authenticationservice.dart';

class Signup extends StatefulWidget {
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TextEditingController firstNamecontroler = TextEditingController();
    TextEditingController lastNamecontroler = TextEditingController();
    TextEditingController emailcontroler = TextEditingController();
    TextEditingController phoneNumbercontroler = TextEditingController();
    TextEditingController passwordcontroler = TextEditingController();
    TextEditingController confirmpasswordcontroler = TextEditingController();

    double heightOfDevice = MediaQuery.of(context).size.height;
    bool _isLoading = false;

    void _input() async {
      await context.read<AuthenticationService>().signUp(
          email: emailcontroler.text.toLowerCase().trim(),
          password: passwordcontroler.text.trim());

      RestApi rest = RestApi();

      await rest.createData(
          firstNamecontroler.text.trim(),
          lastNamecontroler.text.trim(),
          emailcontroler.text.trim(),
          phoneNumbercontroler.text);

      return Navigator.of(context).pop();
    }

    return Scaffold(
      body: FutureBuilder<Object>(
          future: null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              setState(() {
                _isLoading = true;
              });
              return MaterialApp(
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            } else if (snapshot.hasError) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(child: Text("Error Occured")),
                ),
              );
            }

            return Column(
              children: [
                SizedBox(
                  height: heightOfDevice * 0.25,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      logo("Matibabu", 32, Color.fromRGBO(43, 147, 128, 20)),
                      logo("Health Is Wealth", 15, Colors.black)
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    textfields(firstNamecontroler,
                                        "Enter your first name"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    textfields(lastNamecontroler,
                                        "Enter your last name"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    textfields(
                                        emailcontroler, "Enter your email"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    textfields(phoneNumbercontroler,
                                        "Enter phone number"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    passwordFields(
                                        passwordcontroler, "Create password"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    passwordFields(confirmpasswordcontroler,
                                        "Confirm password"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    SizedBox(
                                      height: 42,
                                      width: 196,
                                      child: _isLoading
                                          ? CircularProgressIndicator()
                                          : ElevatedButton(
                                              onPressed: _input,
                                              child: Text("Sign up"),
                                              style: ElevatedButton.styleFrom(
                                                  primary: Color.fromRGBO(
                                                      43, 147, 128, 20)),
                                            ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
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
) {
  return TextFormField(
    controller: textfieldcontroler,

    // ignore: prefer_const_constructors
    decoration: InputDecoration(
      labelText: placeholder,
      //hintText: placeholder
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

Widget passwordFields(
  TextEditingController textfieldcontroler,
  String placeholder,
) {
  return TextFormField(
    controller: textfieldcontroler,
    obscureText: true,

    // ignore: prefer_const_constructors
    decoration: InputDecoration(
      labelText: placeholder,
      //hintText: placeholder
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
