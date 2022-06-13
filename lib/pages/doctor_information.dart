// ignore_for_file: unnecessary_new, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/pages/bookingpage.dart';

class DoctorInfo extends StatelessWidget {
  final String doctorName;
  final String doctorSpecialty;
  final String doctorId;

  DoctorInfo(this.doctorName, this.doctorSpecialty, this.doctorId);

  @override
  Widget build(BuildContext context) {
    double widthOfDevice = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          doctorName,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: doctor_info_body(context, doctorName, doctorId),
    );
  }
}

Widget doctor_info_body(
    BuildContext context, String doctorName, String doctorid) {
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

  String currentHospital = "Karen Hospital";

  return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Doctor")
          .doc(doctorid)
          .snapshots(),
      builder: (context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 200,
            width: 300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Text("Oops. An error occured. Try again later");
        }

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
                      style: TextStyle(
                        fontSize: 18,
                      ),
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
                        snapshot.data!.get("Current Hospital"),
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
                              MaterialPageRoute(
                                  builder: (context) => BookingsPage(
                                      snapshot.data!.get("Current Hospital"),
                                      doctorName)),
                            )),
                        child: Text("Book Appointment"),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.teal,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Contacts:",
                    style: TextStyle(
                        fontSize: 18,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone_outlined),
                    title: Text(snapshot.data!.get("Phone Number")),
                  ),
                  ListTile(
                    leading: Icon(Icons.email_outlined),
                    title: Text(snapshot.data!.get("Email")),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.whatsapp_outlined,
                      color: Colors.green,
                    ),
                    title: Text(snapshot.data!.get("Phone Number")),
                  )
                ],
              ),
            ),
          ],
        );
      });
}

Widget myOwnListtile(
    String placeholder, IconData listtileLeadingIcon, BuildContext context) {
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
