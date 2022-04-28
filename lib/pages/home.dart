// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:matibabu/GlobalComponents/colors.dart';

class home extends StatefulWidget {
  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(43, 147, 128, 20),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 200, 0, 0),
        child: ListView(
          children: [
            Container(
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(30.0),
                  topRight: const Radius.circular(30.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 33,
                  ),
                  textInfo('upcoming appointments'),
                  SizedBox(
                    height: 10,
                  ),
                  info(),
                  SizedBox(
                    height: 33,
                  ),
                  textInfo('My favorite doctors'),
                  SizedBox(
                    height: 10,
                  ),
                  info(),
                  SizedBox(
                    height: 33,
                  ),
                  textInfo('Top ratted specialist'),
                  SizedBox(
                    height: 10,
                  ),
                  info(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget textInfo(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
    child: Text(
      text,
      style: TextStyle(
          color: Color.fromRGBO(43, 147, 128, 20),
          fontSize: 25,
          fontWeight: FontWeight.bold),
    ),
  );
}

Widget infocards() {
  return Container(
    height: 160,
    width: 300,
    child: SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/profile.jpg'),
            radius: 32.0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Dr. Steve Burke",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              Text(
                "25/03/2022",
                style: TextStyle(
                  color: Color.fromARGB(255, 21, 121, 91),
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Text(
            "...",
            style: TextStyle(
                color: Color.fromARGB(255, 21, 121, 91),
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

Widget info() {
  return Container(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 150,
            child: ListView.builder(
              itemCount: 10,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Container(
                height: 200,
                width: 300,
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                  color: Color.fromRGBO(245, 242, 242, 20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/profile.jpg'),
                        radius: 32.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Dr. Steve Burke",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "25/03/2022",
                            style: TextStyle(
                              color: Color.fromARGB(255, 21, 121, 91),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "...",
                        style: TextStyle(
                            color: Color.fromARGB(255, 21, 121, 91),
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
