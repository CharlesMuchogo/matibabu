// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/pages/bookingpage.dart';

class AppointmentPage extends StatelessWidget {
  final String patientId;
  final String doctorUid;
  final String dateOfAppointment;
  final String typeOfConsultation;
  final String timeOfAppointment;
  final String addressOfHospital;
  final String doctorName;
  final String status;

  const AppointmentPage(
    this.patientId,
    this.doctorUid,
    this.dateOfAppointment,
    this.typeOfConsultation,
    this.timeOfAppointment,
    this.addressOfHospital,
    this.doctorName,
    this.status,
  );

  @override
  Widget build(BuildContext context) {
    cancelappointment() {
      if (status == "Cancelled") {
        FirebaseFirestore.instance
            .collection("Patient")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("My appointments")
            .doc(patientId)
            .delete();

        print("deleted successfuly");
      } else {
        FirebaseFirestore.instance
            .collection("Patient")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("My appointments")
            .doc(patientId)
            .delete();

        FirebaseFirestore.instance
            .collection("Doctor")
            .doc(doctorUid)
            .collection("My appointments")
            .doc(patientId)
            .delete();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Appointment details"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            ListTile(
              leading: Icon(Icons.calendar_month_outlined),
              title: Text(dateOfAppointment),
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text(timeOfAppointment),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text(
                addressOfHospital,
              ),
            ),
            ListTile(
              leading: Icon(Icons.medical_services),
              title: Text(
                typeOfConsultation,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text(
                doctorName,
              ),
              //should lead user to the doctors page of specific doctor
            ),
            status == "Cancelled"
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      cancelAppointment(
                          "Delete appointment", cancelappointment, context),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BookingsPage(
                                    typeOfConsultation,
                                    addressOfHospital,
                                    doctorName,
                                    doctorUid),
                              ),
                            );
                          },
                          child: Text("Reschedule appointment"))
                    ],
                  )
                : cancelAppointment(
                    "Cancel appointment", cancelappointment, context),
            status == "Confirmed" ? Container() : Container(),
          ],
        ),
      ),
    );
  }
}

Widget cancelAppointment(
    String name, Function cancelappointment, BuildContext context) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(primary: Colors.red),
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Do you want to cancel the appointment?"),
            actions: [
              MaterialButton(
                elevation: 5,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "No",
                  style: TextStyle(color: Colors.teal, fontSize: 18),
                ),
              ),
              MaterialButton(
                elevation: 5,
                onPressed: () {
                  Navigator.of(context).pop(cancelappointment());
                },
                child: Text(
                  "Yes",
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              )
            ],
          );
        },
      );
    },
    child: Text(name),
  );
}
