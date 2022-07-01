// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RestApi {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> createData(String firstName, String lastName, String email,
      String phoneNumber) async {
    final User? _user = _auth.currentUser;
    final _uid = _user?.uid;

    await _fire.collection("Patient").doc(_uid).set(
      {
        "id": _uid,
        "First Name": firstName,
        "Last Name": lastName,
        "Email": email,
        "Profile Photo": "https://bit.ly/3QR1Z8n",
        "Phone Number": phoneNumber
      },
    );
    return "Signup successful";
  }

  Future<void> readData() async {
    final User? _user = _auth.currentUser;
    final _uid = _user?.uid;
    var userDetailsList = [];

    final DocumentSnapshot docs =
        await _fire.collection("Patient").doc(_uid).get();

    String name = docs.get("Email");
    String phoneNumber = docs.get("Phone Number");

    userDetailsList.add({"Email": name, "Phone Number": phoneNumber});

    return userDetailsList[0];
  }

  Future<String> cancelAppointments(String appointmentId) async {
    try {
      await _fire.collection("Appointment").doc(appointmentId).delete();
      return "Deleted successfuly";
    } on FirebaseFirestore catch (e) {
      return e.toString();
    }
  }

  Future<String> bookAppointment(
      String specialty,
      String time,
      String date,
      String address,
      String doctorName,
      String doctorUid,
      BuildContext context) async {
    final User? _user = _auth.currentUser;
    final _uid = _user?.uid;

    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
    await _fire
        .collection("Patient")
        .doc(_uid)
        .collection("My appointments")
        .doc(date + time)
        .set(
      {
        "Doctor Id": doctorUid,
        "Date": date,
        "Time": time,
        "Consultation": specialty,
        "Address": address,
        "Doctor Name": doctorName,
        "Status": "Pending",
      },
    );
    await _fire
        .collection("Doctor")
        .doc(doctorUid)
        .collection("My appointments")
        .doc(date + time)
        .set(
      {
        "Patient Id": _uid,
        "Date": date,
        "Time": time,
        "Consultation": specialty,
        "Address": address,
        "Status": "Pending",
      },
    );
    Navigator.pop(context);
    final snackBar = SnackBar(
      content: const Text('Your Appointment was booked successfully!'),
      backgroundColor: (Colors.grey[900]),
      action: SnackBarAction(
        label: 'dismiss',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return "You have booked your appointment successfully";
  }
}

class AppointmentDetails {
  String? _uid;
  String? date;
  String? time;
  String? specialty;
  String? address;
  String? doctorName;

  AppointmentDetails();

  Map<String, dynamic> toJson() => {
        "Patient Id": _uid,
        "Date": date,
        "Time": time,
        "Consultation": specialty,
        "Address": address,
        "Doctor Name": doctorName,
        "Status": "Pending",
      };
  AppointmentDetails.fromSnapshot(snapshot)
      : _uid = snapshot.data()["Patient Id"],
        date = snapshot.data()["Patient Id"],
        time = snapshot.data()["Patient Id"],
        specialty = snapshot.data()["Patient Id"],
        address = snapshot.data()["Patient Id"],
        doctorName = snapshot.data()["Patient Id"];
}
