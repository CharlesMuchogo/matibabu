import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RestApi {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createData(String firstName, String lastName, String email,
      String phoneNumber, String address) async {
    final uid = _auth.currentUser?.uid;

    await _fire.collection("Patient").doc(uid).set(
      {
        "id": uid,
        "First Name": firstName,
        "Last Name": lastName,
        "Email": email,
        "Profile Photo": "https://bit.ly/3QR1Z8n",
        "Phone Number": phoneNumber,
        "Address": address,
      },
    );
  }

  Future<Map<String, dynamic>> readData() async {
    final uid = _auth.currentUser?.uid;
    final DocumentSnapshot docs =
        await _fire.collection("Patient").doc(uid).get();

    return {
      "Email": docs.get("Email"),
      "Phone Number": docs.get("Phone Number"),
    };
  }

  Future<String> cancelAppointments(String appointmentId) async {
    try {
      await _fire.collection("Appointment").doc(appointmentId).delete();
      return "Deleted successfuly";
    } on FirebaseException catch (e) {
      return e.toString();
    }
  }

  Future<void> bookAppointment(
    String specialty,
    String time,
    String date,
    String address,
    String doctorName,
    String doctorUid,
  ) async {
    final uid = _auth.currentUser?.uid;

    await _fire
        .collection("Patient")
        .doc(uid)
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
        "Patient Id": uid,
        "Date": date,
        "Time": time,
        "Consultation": specialty,
        "Address": address,
        "Status": "Pending",
      },
    );
  }
}
