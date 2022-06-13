// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchdoctorcontroler = TextEditingController();
  //use  searchdoctorcontroler.text to retrieve contents of the searchbox

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
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(115, 0, 0, 0),
                height: 39,
                width: 368,
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
                child: TextField(
                  controller: searchdoctorcontroler,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      //labelText: 'Enter Name',
                      hintText: 'Search for a doctor'),
                ),
              ),
              SizedBox(
                height: 67,
              ),
              searchinfo()
            ],
          ),
        ),
      ),
    );
  }
}

Widget searchinfo() {
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

        return Container(
          child: Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 630,
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) => Container(
                        height: 100,
                        width: 200,
                        margin: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
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
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/profile.jpg'),
                                radius: 32.0,
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    ("Dr. " +
                                        snapshot.data!.docs[index]
                                            .get("First Name")),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    snapshot.data!.docs[index].get("specialty"),
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 21, 121, 91),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.more_vert_sharp,
                                color: Colors.teal,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
