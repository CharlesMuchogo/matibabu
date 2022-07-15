import 'package:flutter/material.dart';

import 'package:matibabu/GlobalComponents/authenticationservice.dart';
import 'package:matibabu/GlobalComponents/restapi.dart';
import 'package:matibabu/pages/signup.dart';
import 'package:provider/provider.dart';

class SignupFields extends StatelessWidget {
  TextEditingController firstNamecontroler = TextEditingController();
  TextEditingController lastNamecontroler = TextEditingController();
  TextEditingController emailcontroler = TextEditingController();
  TextEditingController phoneNumbercontroler = TextEditingController();
  TextEditingController passwordcontroler = TextEditingController();
  TextEditingController confirmpasswordcontroler = TextEditingController();
  TextEditingController addresscontroler = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void _input() async {
      if ((firstNamecontroler.text.trim().isEmpty ||
          lastNamecontroler.text.trim().isEmpty ||
          emailcontroler.text.trim().isEmpty ||
          phoneNumbercontroler.text.trim().isEmpty ||
          passwordcontroler.text.trim().isEmpty ||
          confirmpasswordcontroler.text.trim().isEmpty ||
          addresscontroler.text.trim().isEmpty)) {
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

      return Navigator.of(context).pop();
    }

    return Column(
      children: [
        textfields(
            firstNamecontroler, "Enter your first name", TextInputType.name),
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
        textfields(
            phoneNumbercontroler, "Enter phone number", TextInputType.number),
        SizedBox(
          height: 10,
        ),
        textfields(addresscontroler, "Enter your address", TextInputType.name),
        SizedBox(
          height: 10,
        ),
        passwordFields(
          passwordcontroler,
          "Create password",
        ),
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
          width: 196,
          child: ElevatedButton(
            onPressed: _input,
            child: Text("Sign up"),
            style: ElevatedButton.styleFrom(
                primary: Color.fromRGBO(43, 147, 128, 20)),
          ),
        )
      ],
    );
  }
}
