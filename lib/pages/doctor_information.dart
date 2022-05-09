// ignore_for_file: unnecessary_new, prefer_const_constructors

import 'package:flutter/material.dart';

class DoctorInfo extends StatelessWidget {
  const DoctorInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dr Steve Burke",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(43, 147, 128, 20),
      ),
      body: doctor_info_body(context),
    );
  }
}

Widget doctor_info_body(BuildContext context) {
  double heightOfDevice = MediaQuery.of(context).size.height;
  return Column(
    children: [
      Container(
        height: heightOfDevice / 4,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: NetworkImage(
                "https://firebasestorage.googleapis.com/v0/b/matibabu-1254d.appspot.com/o/doctor_image.jpeg?alt=media&token=b4c09479-454b-44a4-8686-3d47239c86c3"),
          ),
        ),
      ),
      Container(
        color: Colors.white,
      ),
    ],
  );
}
