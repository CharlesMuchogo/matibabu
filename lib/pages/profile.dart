// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class profile extends StatefulWidget {
  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  String name = 'Lencer Muindi';

  bool isSwitched = false;

  var textValue = 'Switch is OFF';

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
      });
    } else {
      setState(() {
        isSwitched = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 100, 8, 8),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
                "https://static.wbsc.org/assets/cms/0a5ee9d0-b95c-5dc8-ae0e-4e7c1f2550b8.jpg"),
            radius: 70.0,
          ),
          SizedBox(
            height: 10,
          ),
          Text(name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 30,
          ),
          Text(
            "User Information",
            style: TextStyle(
                fontSize: 20,
                color: Color.fromRGBO(43, 147, 128, 20),
                fontWeight: FontWeight.bold),
          ),
          Divider(
            color: Colors.black,
            thickness: 1,
          ),
          SizedBox(
            height: 28,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.email_outlined),
              SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Email",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "muindilencer@gmail.com",
                    style: TextStyle(fontSize: 18),
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 27),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined),
              SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Address",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Maasai Lodge - Ongata Rongai",
                    style: TextStyle(fontSize: 18),
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 28,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.phone),
              SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Phone number",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "0758896593",
                    style: TextStyle(fontSize: 18),
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 27,
          ),
          Text(
            "User Settings",
            style: TextStyle(
                fontSize: 20,
                color: Color.fromRGBO(43, 147, 128, 20),
                fontWeight: FontWeight.bold),
          ),
          Divider(
            color: Colors.black,
            thickness: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.dark_mode,
                size: 30,
              ),
              Text(
                "Dark Mode",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                onChanged: toggleSwitch,
                value: isSwitched,
                activeColor: Colors.black,
                activeTrackColor: Colors.black54,
                inactiveThumbColor: Colors.white54,
                inactiveTrackColor: Colors.white,
              )
            ],
          )
        ],
      ),
    );
  }
}
