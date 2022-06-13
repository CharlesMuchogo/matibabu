// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentPage extends StatelessWidget {
  final String patientId;
  final String dateOfAppointment;
  final String typeOfConsultation;
  final String timeOfAppointment;
  final String addressOfHospital;
  final String doctorName;
  const AppointmentPage(
      this.patientId,
      this.dateOfAppointment,
      this.typeOfConsultation,
      this.timeOfAppointment,
      this.addressOfHospital,
      this.doctorName);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
      ),
    );
  }
}
