// ignore_for_file: unnecessary_new, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launch/flutter_launch.dart';
import 'package:matibabu/pages/bookingpage.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorInfo extends StatelessWidget {
  final String doctorName;
  final String doctorSpecialty;
  final String doctorId;
  final String displayPhotoUrl;

  DoctorInfo(this.doctorName, this.doctorSpecialty, this.doctorId,
      this.displayPhotoUrl);

  @override
  Widget build(BuildContext context) {
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

        Widget displayPhoto() {
          if (snapshot.data!.get("Profile Photo") == "") {
            return Container(
              height: heightOfDevice / 4,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/images/emptyprofile.png"),
                ),
              ),
            );
          }
          return Container(
            height: heightOfDevice / 4,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(snapshot.data!.get("Profile Photo")),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              displayPhoto(),
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
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Current Hospital: ",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          snapshot.data!.get("Current Hospital"),
                          style: TextStyle(
                            fontSize: 15,
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
                                          snapshot.data!
                                              .get("Current Hospital"),
                                          doctorName,
                                          doctorid,
                                        )),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: ListTile(
                        leading: Icon(Icons.phone_outlined),
                        title: Text(snapshot.data!.get("Phone Number")),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: ListTile(
                        leading: Icon(Icons.email_outlined),
                        title: Text(snapshot.data!.get("Email")),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: InkWell(
                        onTap: () async {
                          String phoneNumber =
                              snapshot.data!.get("Phone Number");
                          bool whatsapp =
                              await FlutterLaunch.hasApp(name: "whatsapp");

                          if (whatsapp) {
                            await FlutterLaunch.launchWhatsapp(
                                phone: phoneNumber, message: "Hello");
                          }
                        },
                        child: ListTile(
                          leading: Icon(
                            Icons.whatsapp_outlined,
                            color: Colors.green,
                          ),
                          title: Text(snapshot.data!.get("Phone Number")),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      });
}
