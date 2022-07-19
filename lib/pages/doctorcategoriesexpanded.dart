import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/pages/doctor_information.dart';

class DoctorCategoriesExpanded extends StatefulWidget {
  final String category;

  DoctorCategoriesExpanded({required this.category});

  @override
  State<DoctorCategoriesExpanded> createState() =>
      _DoctorCategoriesExpandedState();
}

class _DoctorCategoriesExpandedState extends State<DoctorCategoriesExpanded> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.category),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("Doctor").snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              print(snapshot.data!.docs.length);

              return SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      ...(snapshot.data!.docs
                          .where(
                        (QueryDocumentSnapshot<Object?> element) =>
                            element["specialty"]
                                .toString()
                                .toLowerCase()
                                .contains(widget.category.toLowerCase()),
                      )
                          .map(
                        (QueryDocumentSnapshot<Object?> data) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 90,
                            margin: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
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
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoctorInfo(
                                      ("Dr. " +
                                          data["First Name"] +
                                          " " +
                                          data["Last Name"]),
                                      data["specialty"],
                                      data["id"],
                                      data["Profile Photo"],
                                      data["Description"],
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 35,
                                    backgroundImage:
                                        NetworkImage(data["Profile Photo"]),
                                  ),
                                  title: Text("Dr. " +
                                      data["First Name"] +
                                      " " +
                                      data["Last Name"]),
                                  subtitle: Text(data["specialty"]),
                                ),
                              ),
                            ),
                          );
                        },
                      )),
                    ],
                  ),
                ),
              );
            }));
  }
}
