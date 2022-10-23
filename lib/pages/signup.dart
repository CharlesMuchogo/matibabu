// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:matibabu/GlobalComponents/authenticationservice.dart';

import 'package:matibabu/GlobalComponents/restapi.dart';
import 'package:matibabu/pages/login.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController firstNamecontroler = TextEditingController();
  TextEditingController lastNamecontroler = TextEditingController();
  TextEditingController emailcontroler = TextEditingController();
  TextEditingController phoneNumbercontroler = TextEditingController();
  TextEditingController passwordcontroler = TextEditingController();
  TextEditingController confirmpasswordcontroler = TextEditingController();

  TextEditingController addresscontroler = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double heightOfDevice = MediaQuery.of(context).size.height;
    bool _isLoading = false;

    void _input() async {
      setState(() {
        _isLoading = true;
      });
      if ((firstNamecontroler.text.trim().isEmpty ||
          lastNamecontroler.text.trim().isEmpty ||
          emailcontroler.text.trim().isEmpty ||
          phoneNumbercontroler.text.trim().isEmpty ||
          passwordcontroler.text.trim().isEmpty ||
          confirmpasswordcontroler.text.trim().isEmpty ||
          addresscontroler.text.trim().isEmpty)) {
        setState(() {
          _isLoading = false;
        });
        return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Error !"),
                content: Text("Fill in all the details"),
                actions: [
                  MaterialButton(
                      child: Text("Okay"),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ],
              );
            });
      } else {
        if (passwordcontroler.text != confirmpasswordcontroler.text) {
          setState(() {
            _isLoading = false;
          });
          return showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Error !"),
                  content: Text("Passwords do not match"),
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
        await context.read<AuthenticationService>().signUp(
            context: context,
            email: emailcontroler.text.toLowerCase().trim(),
            password: passwordcontroler.text.trim());

        RestApi rest = RestApi();

        await rest.createData(
          context,
          firstNamecontroler.text.trim(),
          lastNamecontroler.text.trim(),
          emailcontroler.text.trim(),
          phoneNumbercontroler.text,
          addresscontroler.text.trim(),
        );
      }
      setState(() {
        _isLoading = false;
      });

      return Navigator.of(context).pop();
    }

    return Scaffold(
      body: Container(
        height: heightOfDevice,
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            SizedBox(
              height: heightOfDevice * 0.25,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // logo("Matibabu", 32, Colors.teal),
                  // logo("Health Is Wealth", 15, Colors.black)
                ],
              ),
            ),
            textfields(firstNamecontroler, "Enter your first name",
                TextInputType.name),
            SizedBox(
              height: 10,
            ),
            textfields(
                lastNamecontroler, "Enter your last name", TextInputType.name),
            SizedBox(
              height: 10,
            ),
            textfields(
                emailcontroler, "Enter your email", TextInputType.emailAddress),
            SizedBox(
              height: 10,
            ),
            textfields(phoneNumbercontroler, "Enter phone number",
                TextInputType.phone),
            SizedBox(
              height: 10,
            ),
            textfields(
                addresscontroler, "Enter your address", TextInputType.name),
            SizedBox(
              height: 10,
            ),
            passwordFields(passwordcontroler, "Create password"),
            SizedBox(
              height: 10,
            ),
            passwordFields(confirmpasswordcontroler, "Confirm password"),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 42,
              width: MediaQuery.of(context).size.width * 0.75,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _input,
                      child: Text("Sign up"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(43, 147, 128, 20)),
                    ),
            )
          ],
        ),
      ),
    );
  }
}

Widget textfields(TextEditingController textfieldcontroler, String placeholder,
    TextInputType keboardtype) {
  return TextFormField(
    keyboardType: keboardtype,
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
