import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Alert extends StatelessWidget {
  String message;
  Alert(this.message);

  @override
  Widget build(BuildContext context) {
    return showAlertDialogue(context, message);
  }
}

class ApplicationColors {
  Color appcolor() {
    Color jungleGreen = const Color.fromRGBO(43, 147, 128, 20);
    return jungleGreen;
  }
}

showAlertDialogue(BuildContext context, String message) {
  Widget okButton = ElevatedButton(
    child: const Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  AlertDialog alert = AlertDialog(
    title: const Text("An Error happened"),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
