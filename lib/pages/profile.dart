// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/GlobalComponents/restapi.dart';

class profile extends StatefulWidget {
  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RestApi info = RestApi();

  bool isSwitched = false;

  var textValue = 'Switch is OFF';

  canceldialogue(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Do you want to Logout?"),
            actions: [
              MaterialButton(
                onPressed: null,
                child: Text("cancel"),
              )
            ],
          );
        });
  }

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
      });
    } else {
      setState(() {
        isSwitched = false;
      });
    }
  }

  signOut() async {
    try {
      _auth.signOut();
    } on FirebaseAuth catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Patient")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(8, 100, 8, 8),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://firebasestorage.googleapis.com/v0/b/matibabu-1254d.appspot.com/o/profile.jpg?alt=media&token=f989bf89-8c13-485b-b5ef-8b7013da0413"),
                  radius: 70.0,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      snapshot.data?.get("First Name"),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.02,
                    ),
                    Text(
                      snapshot.data?.get("Last Name"),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "User Information",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold),
                ),
                Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                SizedBox(
                  height: 28,
                ),
                UserInfo(
                    "Email", snapshot.data?.get("Email"), Icons.email_outlined),
                UserInfo("Address", "Maasai Lodge", Icons.location_on_outlined),
                UserInfo(
                  "Phone Number",
                  snapshot.data?.get("Phone Number"),
                  Icons.phone,
                ),
                Text(
                  "User Settings",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold),
                ),
                Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                ListTile(
                  leading: Icon(
                    Icons.dark_mode,
                    size: 30,
                  ),
                  title: Text('Dark Mode'),
                  trailing: Switch(
                    onChanged: toggleSwitch,
                    value: isSwitched,
                    activeColor: Colors.black,
                    activeTrackColor: Colors.black54,
                    inactiveThumbColor: Colors.white54,
                    inactiveTrackColor: Colors.white,
                  ),
                ),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Do you want to Logout?"),
                          actions: [
                            MaterialButton(
                              elevation: 5,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "No",
                                style:
                                    TextStyle(color: Colors.teal, fontSize: 18),
                              ),
                            ),
                            MaterialButton(
                              elevation: 5,
                              onPressed: () {
                                Navigator.of(context).pop(signOut());
                              },
                              child: Text(
                                "Yes",
                                style:
                                    TextStyle(color: Colors.red, fontSize: 18),
                              ),
                            )
                          ],
                        );
                      },
                    );
                  },
                  child: ListTile(
                    title: Text('Logout'),
                    leading: Icon(
                      Icons.logout_outlined,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

Widget UserInfo(String title, String subTitle, IconData icondata) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      child: ListTile(
        onTap: (() {}),
        leading: Icon(icondata),
        title: Text(title),
        subtitle: Text(subTitle),
      ),
    ),
  );
}
