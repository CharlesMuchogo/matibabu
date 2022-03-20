// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:matibabu/homepage/upcoming.dart';

class homepage extends StatelessWidget {
  var name = 'much';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hello $name ',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              Icon(
                Icons.notifications_none,
                color: Colors.black,
              )
            ],
          ),
          backgroundColor: Colors.white,
        ),
        body: UpcomingAppointments(),
      ),
    );
  }
}
