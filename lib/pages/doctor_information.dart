// ignore_for_file: unnecessary_new, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:matibabu/pages/bookingpage.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorInfo extends StatelessWidget {
  final String doctorSpecialty;
  final String doctorName;
  final String doctorId;
  final String doctorDescription;
  final String displayPhotoUrl;

  DoctorInfo(this.doctorSpecialty, this.doctorName, this.doctorId,
      this.displayPhotoUrl, this.doctorDescription);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          doctorName,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: doctor_info_body(context, doctorName, doctorId, doctorDescription),
    );
  }
}

Widget doctor_info_body(BuildContext context, String doctorName,
    String doctorid, String doctorDescription) {
  double heightOfDevice = MediaQuery.of(context).size.height;

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
                      padding: const EdgeInsets.all(30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Current Hospital: ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            snapshot.data!.get("Current Hospital"),
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: SizedBox(
                        child: ElevatedButton(
                          onPressed: (() => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BookingsPage(
                                        snapshot.data!.get("Current Hospital"),
                                        doctorName,
                                        doctorid,
                                        snapshot.data!.get("specialty"))),
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
                        onTap: ()async{
                          await launchUrl(Uri.parse("tel://${snapshot.data!.get("Phone Number")}"));
                          },
                        leading: Icon(Icons.phone_outlined, color: Colors.teal,),
                        title: Text(snapshot.data!.get("Phone Number")),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: ListTile(
                        onTap: ()async{
                          await launchUrl(Uri.parse("mailto:${snapshot.data!.get("Email")}"));
                        },
                        leading: Icon(Icons.email_outlined, color: Colors.teal,),
                        title: Text(snapshot.data!.get("Email")),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: InkWell(
                        onTap: () async {
                          String phoneNumber =
                              snapshot.data!.get("Phone Number");

                          if (phoneNumber.startsWith("07")) {
                            phoneNumber = "+254" + phoneNumber.substring(1);
                          }
                          var whatsappUrl = "whatsapp://send?phone=" +
                              phoneNumber +
                              "&text=hello";

                          if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                            await launchUrl(Uri.parse(whatsappUrl));
                          }
                        },
                        child: ListTile(
                          leading:  FaIcon(
                            FontAwesomeIcons.whatsapp,
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
