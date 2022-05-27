import 'package:flutter/material.dart';

class UpdateDetails extends StatefulWidget {
  @override
  State<UpdateDetails> createState() => _UpdateDetailsState();
}

class _UpdateDetailsState extends State<UpdateDetails> {
  @override
  Widget build(BuildContext context) {
    TextEditingController namecontroler = TextEditingController();
    TextEditingController addresscontroler = TextEditingController();
    TextEditingController phonenumbercontroler = TextEditingController();
    void updateDetails() {}
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: namecontroler,
          ),
          TextField(
            controller: addresscontroler,
          ),
          TextField(
            controller: phonenumbercontroler,
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
