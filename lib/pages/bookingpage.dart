// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:internationalization/internationalization.dart';
import 'package:matibabu/GlobalComponents/restapi.dart';

class BookingsPage extends StatefulWidget {
  @override
  State<BookingsPage> createState() => _BookingsPageState();
  final String address;
  final String doctorName;
  final String doctorUid;

  const BookingsPage(
    this.address,
    this.doctorName,
    this.doctorUid,
  );
}

String _selectedDate = "";
String formatedTime = "";
String timeOfAppointment = "";

class _BookingsPageState extends State<BookingsPage> {
  Future<void> _openDatePicker(BuildContext context) async {
    DateTime initialdate = DateTime.now();

    if (DateTime.now().weekday == 6) {
      setState(() {
        initialdate = initialdate.add(Duration(days: 2));
      });
    }
    if (DateTime.now().weekday == 7) {
      setState(() {
        initialdate = initialdate.add(Duration(days: 1));
      });
    }

    final DateTime? date = await showDatePicker(
      context: context,
      selectableDayPredicate: (DateTime val) =>
          val.weekday == 6 || val.weekday == 7 ? false : true,
      initialDate: initialdate,
      firstDate: DateTime.now(),
      helpText: "Select date of appointment",
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (date != null) {
      setState(
        () {
          _selectedDate = DateFormat.yMMMd("en_US").format(date).toString();
        },
      );
    }
    //return _selectedDate;
  }

  TimeOfDay selectedTime = TimeOfDay.now();

  Widget selectTime(String time) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
          onPressed: () {
            setState(() {
              timeOfAppointment = time;
            });
          },
          child: Text(time)),
    );
  }

  _selectTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null && timeOfDay != selectedTime) {
      setState(() {
        selectedTime = timeOfDay;
        formatedTime = "${selectedTime.hour}:${selectedTime.minute}";
      });
    }
  }

  book() {
    if ((timeOfAppointment.isEmpty) || (_selectedDate.isEmpty)) {
      return Text(
        "Fill in all details",
        style: TextStyle(
            color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
      );
    } else {
      RestApi restObject = RestApi();
      restObject.bookAppointment(
          _dropdownValue,
          timeOfAppointment,
          _selectedDate,
          widget.address,
          widget.doctorName,
          widget.doctorUid,
          context);

      return Container();
    }
  }

  List<String> doctorSpecialties = [
    "Therapy",
    "Cardiology",
    "Gaenacology",
    "Neurology",
    "Dentist"
  ];

  String _dropdownValue = "Therapy";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book An Appointment"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: (MediaQuery.of(context).size.height * 0.15),
            child: Center(child: Text("")),
          ),
          ListTile(
            leading: Icon(Icons.medical_services_outlined),
            title: Text("Select the type of Appointment"),
            trailing: DropdownButton(
              value: _dropdownValue,
              onChanged: (value) {
                setState(() {
                  _dropdownValue = value.toString();
                });
              },
              items: doctorSpecialties.map((String items) {
                return DropdownMenuItem(
                  value: items,
                  child: Text(items),
                );
              }).toList(),
            ),
          ),
          InkWell(
            onTap: () => _openDatePicker(context),
            child: ListTile(
              leading: Icon(Icons.calendar_month_outlined),
              title: Text("Select date of the Appointment"),
              trailing: Text(_selectedDate),
            ),
          ),
          InkWell(
            onTap: () {
              // _selectTime(context);
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    // return GetAppointmentTime(
                    //     widget.doctorUid, context, _selectedDate);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SingleChildScrollView(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  selectTime("08:00 AM"),
                                  selectTime("08:30 AM"),
                                  selectTime("09:00 AM"),
                                  selectTime("09:30 AM"),
                                  selectTime("10:00 AM"),
                                ],
                              ),
                              Column(
                                children: [
                                  selectTime("10:30 AM"),
                                  selectTime("11:00 AM"),
                                  selectTime("11:30 AM"),
                                  selectTime("12:00 PM"),
                                  selectTime("12:30 PM"),
                                ],
                              ),
                              Column(
                                children: [
                                  selectTime("2:00 PM"),
                                  selectTime("2:30 PM"),
                                  selectTime("3:00 PM"),
                                  selectTime("3:30 PM"),
                                  selectTime("4:00 PM")
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    );
                  });
            },
            child: ListTile(
              leading: Icon(Icons.watch_later_outlined),
              title: Text("Select time of the Appointment"),
              trailing: Text(timeOfAppointment),
            ),
          ),
          ElevatedButton(
            onPressed: book,
            child: Text("Book Appointment"),
          )
        ],
      ),
    );
  }
}

Widget GetAppointmentTime(String doctorUid, BuildContext context, String date) {
  List appointmenttime = ["Today"];
  return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Doctor")
          .doc(doctorUid)
          .collection("My Appointments")
          .snapshots(),
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

        snapshot.data!.docs
            .where(
          (QueryDocumentSnapshot<Object?> element) =>
              element["Date"].toString().contains(""),
        )
            .map((QueryDocumentSnapshot<Object?> data) {
          print(data["Time"]);
          appointmenttime.add(data["Time"]);
        });

        print(appointmenttime.length);
        return Column(
          children: appointmenttime.map((e) => Text(e)).toList(),
        );
      });
}
