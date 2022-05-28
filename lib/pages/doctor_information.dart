// ignore_for_file: unnecessary_new, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:matibabu/pages/bookingpage.dart';

class DoctorInfo extends StatelessWidget {
  const DoctorInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double widthOfDevice = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dr Steve Burke",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(43, 147, 128, 20),
      ),
      body: doctor_info_body(context),
    );
  }
}

Widget doctor_info_body(
  BuildContext context,
) {
  double heightOfDevice = MediaQuery.of(context).size.height;
  String doctorDescription =
      "I have 23 years of experience working as a dentist."
      "I have worked in various famous hospitals such as "
      "Nairobi hospital"
      "Aga Khan Hospital"
      "Karen hospital "
      "Right now I’m the head of Dentistry department in"
      "Kenyatta National Hospital."
      "Feel free to contact me to book an appointment.  ";
  return Column(
    children: [
      Container(
        height: heightOfDevice / 4,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(
                "https://firebasestorage.googleapis.com/v0/b/matibabu-1254d.appspot.com/o/doctor_image.jpeg?alt=media&token=b4c09479-454b-44a4-8686-3d47239c86c3"),
          ),
        ),
      ),
      Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  right: 30, left: 30, top: 20, bottom: 20),
              child: Text(
                doctorDescription,
                style: TextStyle(fontSize: 18, letterSpacing: 1),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Current Hospital: ",
                  style: TextStyle(
                      fontSize: 18,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Karen Hospital",
                  style: TextStyle(
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                child: ElevatedButton(
                  onPressed: (() => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BookingsPage()),
                      )),
                  child: Text("Book Appointment"),
                ),
              ),
            ),
            Text(
              "Contacts:",
              style: TextStyle(
                  fontSize: 18, letterSpacing: 1, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: Icon(Icons.phone_outlined),
              title: Text("+254758896593"),
            ),
            ListTile(
              leading: Icon(Icons.email_outlined),
              title: Text("muchpaul2@gmail.com"),
            ),
            ListTile(
              leading: Icon(Icons.whatsapp_outlined),
              title: Text("+254758896593"),
            )
          ],
        ),
      ),
    ],
  );
}

Widget myOwnListtile(
    String placeholder, IconData listtileLeadingIcon, BuildContext context) {
  double widthOfDevice = MediaQuery.of(context).size.width;

  return Padding(
    padding: const EdgeInsets.only(
        left: double.infinity * 0.25, top: 10, bottom: 10, right: 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(listtileLeadingIcon),
        SizedBox(
          width: 30,
        ),
        Text(placeholder),
      ],
    ),
  );
}
