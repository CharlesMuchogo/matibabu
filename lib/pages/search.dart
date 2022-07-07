// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/pages/doctor_information.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchdoctorcontroler = TextEditingController();

  void _printLatestValue() {
    print("$searchdoctorcontroler.text");
  }

  @override
  void initState() {
    super.initState();

    searchdoctorcontroler.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    searchdoctorcontroler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Search For a Doctor"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    height: 39,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                      color: Color.fromRGBO(245, 242, 242, 10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Container(
                      width: 300,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: TextField(
                          controller: searchdoctorcontroler,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              //labelText: 'Enter Name',
                              hintText: 'Search for a doctor'),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      searchdoctorcontroler.text =
                          searchdoctorcontroler.text.trim();
                    });
                  },
                  icon: Icon(Icons.search),
                )
              ],
            ),
            searchinfo(searchdoctorcontroler.text)
          ],
        ),
      ),
    );
  }
}

Widget searchinfo(String controler) {
  return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Doctor").snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Oops, an error occured. please try again"),
          );
        }
        if (snapshot.data!.docs.length < 1) {
          return Center(
            child: Text("No results found for your search"),
          );
        }

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
                          .contains(controler.toLowerCase()),
                )
                    .map(
                  (QueryDocumentSnapshot<Object?> data) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.1,
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
      });
}
