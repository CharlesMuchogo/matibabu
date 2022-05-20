import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matibabu/GlobalComponents/authenticationservice.dart';

class RestApi {
  //String firstName;
  //String lastName;
  //String email;
  //String phoneNumber;
  //RestApi(this.firstName, this.lastName, this.email, this.phoneNumber);

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
}
