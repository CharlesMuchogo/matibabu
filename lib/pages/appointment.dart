// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';

class AppointmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double widthOfDevice = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Appointment"),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(43, 147, 128, 20),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Text(
              "Time: ",
            ),
            title: Text("date of appointment"),
            subtitle: Text("time of appointment"),
          ),
          ListTile(
            leading: Text(
              "Address: ",
            ),
            title: Text(
              "Address of the hospital: ",
            ),
          ),
          ListTile(
            leading: Text(
              "Condultation: ",
            ),
            title: Text(
              "purpose of appointment",
            ),
          ),
          ListTile(
            leading: Text(
              "Doctor: ",
            ),
            title: Text(
              "Doctor name",
            ),
            subtitle: Text(
              "contats- telephone number",
            ), //should lead user to the doctors page of specific doctor
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: null,
                child: Text("Cancel Appointment"),
              ),
              ElevatedButton(
                onPressed: null,
                child: Text("Reschedule Appointment"),
              )
            ],
          ),
        ],
      ),
    );
  }
}
