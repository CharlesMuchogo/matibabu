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
                "https://firebasestorage.googleapis.com/v0/b/matibabu-1254d.appspot.com/o/profile.jpg?alt=media&token=f989bf89-8c13-485b-b5ef-8b7013da0413"),
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
          UserInfo("Email", "Muchpaul2@gmail.com", Icons.email_outlined),
          UserInfo("Address", "Maasai Lodge", Icons.location_on_outlined),
          UserInfo(
            "Phone Number",
            "0758896593",
            Icons.phone,
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
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.logout_outlined,
                size: 30,
              ),
              Text(
                "Logout",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                width: 10,
              )
            ],
          )
        ],
      ),
    );
  }
}

Widget UserInfo(String title, String subTitle, IconData icondata) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      child: ListTile(
        onTap: (() {}),
        leading: Icon(icondata),
        title: Text(title),
        subtitle: Text(subTitle),
      ),
    ),
  );
}
