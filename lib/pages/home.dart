// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:matibabu/pages/appointment.dart';
import 'package:matibabu/pages/doctor_information.dart';
import 'package:matibabu/pages/doctorcartegories.dart';
import 'package:matibabu/pages/doctorcategoriesexpanded.dart';

class home extends StatefulWidget {
  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  @override
  Widget build(BuildContext context) {
    double heightOfDevice = MediaQuery.of(context).size.height;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? _user = _auth.currentUser;
    final _uid = _user?.uid;

    return Scaffold(
      backgroundColor: Colors.teal,
      body: Column(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Patient")
                  .doc(_uid)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("An error occured. Hold on as we fix it "),
                  );
                }

                var hour = DateTime.now().hour;
                String greeting() {
                  hour = DateTime.now().hour;

                  if (hour < 12) {
                    return 'Good Morning';
                  }
                  if (hour < 17) {
                    return 'Good Afternoon';
                  }
                  return 'Good Evening';
                }

                return Container(
                  height: heightOfDevice * 0.2,
                  width: double.infinity,
                  color: Colors.teal,
                  child: Center(
                    child: Text(
                      greeting() + " " + snapshot.data?.get("First Name"),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(30.0),
                      topRight: const Radius.circular(30.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 33,
                      ),
                      textInfo('Upcoming appointments'),
                      SizedBox(
                        height: 10,
                      ),
                      upcomingAppointments(_uid!),
                      SizedBox(
                        height: 15,
                      ),
                      textInfo('Top rated specialists'),
                      SizedBox(
                        height: 10,
                      ),
                      doctorInfoCard(),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          textInfo('Doctor Categories'),
                          MaterialButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DoctorCartegories()),
                              ); // navigate to Appointments page
                            },
                            child: Text(
                              "See all",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.teal),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      cartegoriesCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget textInfo(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
    child: Text(
      text,
      style: TextStyle(
          color: Colors.teal, fontSize: 25, fontWeight: FontWeight.bold),
    ),
  );
}

Widget doctorInfoCard() {
  return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Doctor").snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
          return Text("An error occured. please try again later");
        }

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 150,
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => Container(
                    height: 200,
                    width: 300,
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                      color: Color.fromRGBO(245, 242, 242, 20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: infocards(
                          context,
                          ("Dr. " +
                              snapshot.data!.docs[index].get("First Name") +
                              " " +
                              snapshot.data!.docs[index].get("Last Name")),
                          snapshot.data!.docs[index].get("Profile Photo"),
                          snapshot.data!.docs[index].get("specialty"),
                          snapshot.data!.docs[index].id,
                          snapshot.data!.docs[index].get("Description")),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
}

Widget infocards(BuildContext context, String name, String displayPhoto,
    String doctorSpecialty, String doctorId, String doctorDescription) {
  Widget profilePhoto(BuildContext context, String profileUrl) {
    if (profileUrl == "") {
      return CircleAvatar(
        backgroundImage: AssetImage("assets/images/emptyprofile.png"),
        radius: 32,
      );
    }
    return CircleAvatar(
      backgroundImage: NetworkImage(profileUrl),
      radius: 32,
    );
  }

  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorInfo(
            doctorSpecialty,
            name,
            doctorId,
            displayPhoto,
            doctorDescription,
          ),
        ),
      ); // navigate to Appointments page
    },
    child: ListTile(
      leading: profilePhoto(context, displayPhoto),
      title: Text(
        name,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
      ),
      subtitle: Text(
        doctorSpecialty,
        style: TextStyle(
          color: Color.fromARGB(255, 21, 121, 91),
          fontSize: 15,
        ),
      ),
      trailing: Icon(
        Icons.more_vert,
        color: Color.fromARGB(255, 21, 121, 91),
      ),
    ),
  );
}

Widget upcomingAppointments(String _uid) {
  return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Patient")
          .doc(_uid)
          .collection("My appointments")
          .orderBy("Date", descending: false)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 150,
            width: 300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Text("Oops. An error occured. Try again later");
        }
        if (snapshot.data!.size <= 0) {
          return SizedBox(
            height: 150,
            width: 300,
            child: Center(
              child: Text(
                "You have no upcomming appointments",
                style: TextStyle(fontSize: 17),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 150,
                child: ListView.builder(
                  itemCount: snapshot.data?.size,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => Container(
                    height: 200,
                    width: 300,
                    margin: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                      color: Color.fromRGBO(245, 242, 242, 20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointmentPage(
                                snapshot.data!.docs[index].id,
                                snapshot.data!.docs[index]["Doctor Id"],
                                snapshot.data!.docs[index]["Date"],
                                snapshot.data!.docs[index]["Consultation"],
                                snapshot.data!.docs[index]["Time"],
                                snapshot.data!.docs[index]["Address"],
                                snapshot.data!.docs[index]["Doctor Name"],
                                snapshot.data!.docs[index]["Status"],
                              ),
                            ),
                          ); // navigate to Appointments page
                        },
                        child: appointmentcards(
                          context,
                          snapshot.data!.docs[index]["Time"],
                          snapshot.data!.docs[index]["Address"],
                          snapshot.data!.docs[index].id,
                          snapshot.data!.docs[index]["Date"],
                          snapshot.data!.docs[index]["Consultation"],
                          snapshot.data!.docs[index]["Doctor Name"],
                          snapshot.data!.docs[index]["Status"],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
}

Widget appointmentcards(
  BuildContext context,
  String time,
  String address,
  String patientId,
  String dateOfAppointment,
  String consultation,
  String doctorName,
  String appointmentStatus,
) {
  return Column(
    children: [
      ListTile(
        title: Text(doctorName),
        subtitle: Text(consultation),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: Colors.grey,
              ),
              SizedBox(
                width: 5,
              ),
              Text(dateOfAppointment),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.grey,
              ),
              SizedBox(
                width: 5,
              ),
              Text(time),
            ],
          ),
          Row(
            children: [
              Icon(Icons.circle,
                  size: 13,
                  color: appointmentStatus == "Pending"
                      ? Colors.amber[700]
                      : appointmentStatus == "Confirmed"
                          ? Colors.green
                          : appointmentStatus == "Cancelled"
                              ? Colors.red
                              : Colors.white),
              SizedBox(
                width: 5,
              ),
              Text(appointmentStatus),
            ],
          ),
        ],
      )
    ],
  );
}

Widget cartegoriesCard() {
  return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection("Doctor Categoty").snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 200,
            width: 150,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Text("An error occured. please try again later");
        }

        return SingleChildScrollView(
          child: SizedBox(
            height: 150,
            child: ListView.builder(
              itemCount: snapshot.data!.size,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Container(
                height: 250,
                width: 180,
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                  color: Color.fromRGBO(245, 242, 242, 20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorCategoriesExpanded(
                              category: snapshot.data!.docs[index].id),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                              snapshot.data!.docs[index]["DisplayPhoto"]),
                          radius: 35,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(snapshot.data!.docs[index].id)
                      ],
                    ),
                  ),
                )),
              ),
            ),
          ),
        );
      });
}
