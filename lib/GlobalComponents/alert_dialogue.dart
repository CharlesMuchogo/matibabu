// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';


class ShowAlert extends StatelessWidget {
  const ShowAlert({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: showAlertDialog(context),
    );
  }
}

showAlertDialog(BuildContext context) {
  // Create button

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Cancel Appointment"),
    content: Text("Do you want to cacel this appointment"),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(
          "No",
          style: TextStyle(color: Colors.black),
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(
          "Yes",
          style: TextStyle(color: Colors.red),
        ),
      ),
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
