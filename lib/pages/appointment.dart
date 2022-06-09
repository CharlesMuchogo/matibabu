// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentPage extends StatelessWidget {
  final String patientId;
  final String dateOfAppointment;
  final String typeOfConsultation;

  const AppointmentPage(
      this.patientId, this.dateOfAppointment, this.typeOfConsultation);

  @override
  Widget build(BuildContext context) {
    void cancel() {
      FirebaseFirestore.instance
          .collection("Appointments")
          .doc(patientId)
          .delete();

      return Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Appointment"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Text(
              "Time: ",
            ),
            title: Text(dateOfAppointment),
            subtitle: Text("time of appointment"),
          ),
          ListTile(
            leading: Text(
              "Address: ",
            ),
            title: Text(
              "Address of the hospital: ",
            ),
          ),
          ListTile(
            leading: Text(
              "Condultation: ",
            ),
            title: Text(
              typeOfConsultation,
            ),
          ),
          ListTile(
            leading: Text(
              "Doctor: ",
            ),
            title: Text(
              "Doctor name",
            ),
            subtitle: Text(
              "contats- telephone number",
            ), //should lead user to the doctors page of specific doctor
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: cancel,
                child: Text("Cancel Appointment"),
              ),
              ElevatedButton(
                onPressed: null,
                child: Text("Reschedule Appointment"),
              )
            ],
          ),
        ],
      ),
    );
  }
}
