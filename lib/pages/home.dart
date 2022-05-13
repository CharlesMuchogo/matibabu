// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:matibabu/pages/doctor_information.dart';

class home extends StatefulWidget {
  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  var hour;

  String greeting() {
    setState(() {
      hour = DateTime.now().hour;
    });

    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  String name = 'Lencer';
  @override
  Widget build(BuildContext context) {
    double heightOfDevice = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.fromRGBO(43, 147, 128, 20),
      body: Column(
        children: [
          Container(
            height: heightOfDevice / 4,
            width: double.infinity,
            color: Color.fromRGBO(43, 147, 128, 20),
            child: Center(
              child: Text(
                greeting() + " " + name,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
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
                      textInfo('Upcoming appointments'),
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
                      InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DoctorInfo()),
                            );
                          },
                          child: info()),
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
        ],
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
                  child: infocards("Charles Muchogo",
                      'assets/images/profile.jpg', "Gaenacologist"),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget infocards(String name, String displayPhoto, String doctorSpecialty) {
  return ListTile(
    leading: CircleAvatar(
      backgroundImage: AssetImage(displayPhoto),
      radius: 32.0,
    ),
    title: Text(
      name,
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
    ),
    subtitle: Text(
      doctorSpecialty,
      style: TextStyle(
        color: Color.fromARGB(255, 21, 121, 91),
        fontSize: 15,
      ),
    ),
    trailing: Icon(
      Icons.more_vert,
      color: Color.fromARGB(255, 21, 121, 91),
    ),
  );
}
