// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class UpcomingAppointments extends StatefulWidget {
  @override
  _UpcomingAppointmentsState createState() => _UpcomingAppointmentsState();
}

class _UpcomingAppointmentsState extends State<UpcomingAppointments> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Card(
          elevation: 1.0,
          child: Container(
            height: 100,
            width: 200,
            child: Row(children: [
              CircleAvatar(
                // ignore: prefer_const_constructors
                backgroundImage: AssetImage('assets/images/profile.jpg'),
                radius: 40.0,
              ),
              SizedBox(
                width: 60.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dr Charles Muchogo",
                    style: TextStyle(
                        color: Colors.black, fontSize: 16, letterSpacing: 1.5),
                  ),
                  Text(
                    "Appointment time: " + "Thursday 10 2022 12:00 PM ",
                    style: TextStyle(
                        color: Colors.black, fontSize: 16, letterSpacing: 1.5),
                  ),
                ],
              )
            ]),
          ),
        )
      ],
    );
  }
}
