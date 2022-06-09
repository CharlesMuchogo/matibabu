// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  ) async {
    final User? _user = _auth.currentUser;
    final _uid = _user?.uid;

    await _fire.collection("Appointments").doc().set(
      {
        "Patient Id": _uid,
        "Date": date,
        "Time": time,
        "Consultation": specialty,
        "Address": address,
      },
    );
    return "You have booked successfully";
  }
}
