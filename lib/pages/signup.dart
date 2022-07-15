// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:matibabu/pages/login.dart';
import 'package:matibabu/pages/signupfields.dart';

class Signup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double heightOfDevice = MediaQuery.of(context).size.height;

    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: heightOfDevice * 0.25,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                logo("Matibabu", 32, Colors.teal),
                logo("Health Is Wealth", 15, Colors.black)
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                    padding: EdgeInsets.all(20), child: SignupFields()),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}

Widget textfields(TextEditingController textfieldcontroler, String placeholder,
    TextInputType keyboardtype) {
  return TextFormField(
    keyboardType: keyboardtype,
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
